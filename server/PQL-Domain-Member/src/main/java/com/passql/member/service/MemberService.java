package com.passql.member.service;

import com.passql.common.util.MemberActivityLogger;
import com.passql.common.util.UuidUtils;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.AdminRequestContext;
import com.passql.common.util.NicknameGenerator;
import com.passql.common.util.UuidUtils;
import com.passql.member.auth.repository.RefreshTokenRepository;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.constant.MemberStatus;
import com.passql.member.dto.ChoiceGenerationModeUpdateRequest;
import com.passql.member.dto.ChoiceGenerationModeUpdateResponse;
import com.passql.member.dto.MemberMeResponse;
import com.passql.member.dto.NicknameChangeRequest;
import com.passql.member.dto.NicknameChangeResponse;
import com.passql.member.dto.NicknameCheckResponse;
import com.passql.member.dto.NicknameRegenerateResponse;
import com.passql.member.entity.Member;
import com.passql.member.entity.MemberSuspendHistory;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.MemberSuspendHistoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;


@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberService {

    /** last_seen_at throttle 간격 (분) — 5분 이내 재호출은 UPDATE 스킵 */
    private static final long LAST_SEEN_THROTTLE_MINUTES = 5L;

    /** UNIQUE 충돌(nickname race) 재시도 횟수. */
    private static final int UNIQUE_CONFLICT_RETRY = 3;

    // 탈퇴 삭제 사유 (member.deleted_by): 본인, 관리자
    private static final String SELF_WITHDRAW_REASON = "SELF_WITHDRAW";
    private static final String ADMIN_WITHDRAW_REASON = "ADMIN_WITHDRAW";

    private final MemberRepository memberRepository;
    private final NicknameGenerator nicknameGenerator;
    private final MemberSuspendHistoryRepository memberSuspendHistoryRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 본인 정보 조회 + last_seen_at throttled 갱신. */
    @Transactional
    public MemberMeResponse getMe(UUID memberUuid) {
        Member member = findActiveMember(memberUuid);
        touchLastSeenIfStale(member);
        checkAndAutoUnsuspendIfExpired(member);
        return MemberMeResponse.from(member);
    }

    /**
     * 제재 상태 체크.
     * <ul>
     *   <li>만료된 경우 → 자동 해제 후 통과</li>
     *   <li>만료 전(또는 영구 제재) → {@link ErrorCode#MEMBER_SUSPENDED} 예외</li>
     *   <li>SUSPENDED 아님 → 통과</li>
     * </ul>
     */
    private void checkAndAutoUnsuspendIfExpired(Member member) {
        if (member.getStatus() != MemberStatus.SUSPENDED) {
            return;
        }
        LocalDateTime until = member.getSuspendUntil();
        if (until != null && until.isBefore(LocalDateTime.now())) {
            member.setStatus(MemberStatus.ACTIVE);
            member.setSuspendUntil(null);
            memberSuspendHistoryRepository.save(MemberSuspendHistory.ofUnsuspend(member.getMemberUuid(), AdminRequestContext.SYSTEM_ACTOR));
            log.info("Member auto-unsuspended on getMe: uuid={}", member.getMemberUuid());
            return;
        }
        log.warn("Suspended member access blocked: uuid={}, until={}", member.getMemberUuid(), until);
        throw new CustomException(ErrorCode.MEMBER_SUSPENDED);
    }

    /**
     * 회원 탈퇴(앱스토어 심사 필수 기능).
     *
     * <p>개인정보(이메일, 소셜 식별자)는 즉시 비우고 닉네임은 익명화한다.
     * 풀이 기록은 통계 보존을 위해 남기되 더 이상 본인과 연결되지 않는다.
     * 소셜 식별자를 비우므로 같은 계정으로 다시 로그인하면 새 회원으로 가입된다.
     * 발급된 리프레시 토큰은 삭제해 즉시 재발급을 막는다(액세스 토큰은 만료까지 유효하나
     * 이후 회원 조회가 모두 MEMBER_NOT_FOUND 로 거절된다).
     */
    @Transactional
    public void withdraw(UUID memberUuid) {
        anonymizeAndWithdraw(findActiveMember(memberUuid), SELF_WITHDRAW_REASON);
    }

    /** 관리자 탈퇴 처리 (#479): 본인 탈퇴와 같은 익명화 + 삭제 사유 ADMIN_WITHDRAW + 감사 기록 */
    @Transactional
    public void withdrawByAdmin(UUID memberUuid) {
        Member member = findActiveMember(memberUuid);
        String nicknameBeforeWithdraw = member.getNickname();
        anonymizeAndWithdraw(member, ADMIN_WITHDRAW_REASON);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.WITHDRAW,
            AdminAuditEvent.summary("nickname", nicknameBeforeWithdraw), AdminAuditEvent.summary("status", MemberStatus.WITHDRAWN)));
    }

    /** 탈퇴 공통: 상태·개인정보 익명화 > 소프트 삭제(사유) > 리프레시 토큰 삭제 */
    private void anonymizeAndWithdraw(Member member, String deleteReason) {
        UUID memberUuid = member.getMemberUuid();
        member.setStatus(MemberStatus.WITHDRAWN);
        member.setWithdrawnAt(LocalDateTime.now());
        // 닉네임은 유니크라 회원 UUID 일부를 붙여 익명화한다.
        member.setNickname("탈퇴회원_" + UuidUtils.toShortForm(memberUuid));
        member.setEmail(null);
        member.setEmailVerified(false);
        member.setProviderUserId("withdrawn:" + memberUuid);
        member.softDelete(deleteReason);

        refreshTokenRepository.delete(memberUuid);
        MemberActivityLogger.recordMemberWithdrawn(memberUuid);
    }

    /** 닉네임 재생성. */
    @Transactional
    public NicknameRegenerateResponse regenerateNickname(UUID memberUuid) {
        Member member = findActiveMember(memberUuid);
        for (int attempt = 1; attempt <= UNIQUE_CONFLICT_RETRY; attempt++) {
            String newNickname = generateUniqueNicknameOrThrow();
            member.setNickname(newNickname);
            try {
                memberRepository.saveAndFlush(member);
                log.info("Nickname regenerated: uuid={}, nickname={}", memberUuid, newNickname);
                return new NicknameRegenerateResponse(newNickname);
            } catch (DataIntegrityViolationException e) {
                log.warn("Nickname UNIQUE conflict on regenerate (attempt {}/{}): uuid={}, nickname={}",
                    attempt, UNIQUE_CONFLICT_RETRY, memberUuid, newNickname);
                if (attempt == UNIQUE_CONFLICT_RETRY) {
                    throw new CustomException(ErrorCode.NICKNAME_GENERATION_FAILED, e);
                }
            }
        }
        throw new CustomException(ErrorCode.NICKNAME_GENERATION_FAILED);
    }

    // 닉네임 중복 확인 — 유효성은 컨트롤러 @Valid에서 처리
    @Transactional(readOnly = true)
    public NicknameCheckResponse checkNickname(String nickname) {
        boolean available = !memberRepository.existsByNicknameAndIsDeletedFalse(nickname);
        return new NicknameCheckResponse(available);
    }

    /** 선택지 생성 모드 조회 — 미존재·탈퇴 회원은 PRACTICE 폴백. */
    public ChoiceGenerationMode getChoiceGenerationMode(UUID memberUuid) {
        return memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
                .map(Member::getChoiceGenerationMode)
                .orElseGet(() -> {
                    log.warn("[member] choiceGenerationMode 조회 실패, PRACTICE 폴백: memberUuid={}", memberUuid);
                    return ChoiceGenerationMode.PRACTICE;
                });
    }

    /** 선택지 생성 모드 변경 — 트랜잭션 내 즉시 반영. */
    @Transactional
    public ChoiceGenerationModeUpdateResponse updateChoiceGenerationMode(
            UUID memberUuid, ChoiceGenerationModeUpdateRequest request) {
        Member member = findActiveMember(memberUuid);
        member.setChoiceGenerationMode(request.getChoiceGenerationMode());
        return new ChoiceGenerationModeUpdateResponse(member.getChoiceGenerationMode());
    }

    // 닉네임 직접 변경 — 쿨다운, 중복 검증 포함
    @Transactional
    public NicknameChangeResponse changeNickname(UUID memberUuid, NicknameChangeRequest request) {
        Member member = findActiveMember(memberUuid);

        // 3일 쿨다운 체크
        if (member.isNicknameChangeCooldown()) {
            throw new CustomException(ErrorCode.NICKNAME_COOLDOWN);
        }

        // 중복 체크 (본인 제외)
        String newNickname = request.nickname();
        if (!newNickname.equals(member.getNickname())
                && memberRepository.existsByNicknameAndIsDeletedFalse(newNickname)) {
            throw new CustomException(ErrorCode.NICKNAME_DUPLICATE);
        }

        member.changeNickname(newNickname);
        return new NicknameChangeResponse(member.getNickname());
    }

    // === 내부 헬퍼 ===

    private Member findActiveMember(UUID memberUuid) {
        return memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
            .orElseThrow(() -> {
                log.warn("Member not found: uuid={}", memberUuid);
                return new CustomException(ErrorCode.MEMBER_NOT_FOUND);
            });
    }

    private String generateUniqueNicknameOrThrow() {
        try {
            return nicknameGenerator.generateUnique(
                memberRepository::existsByNicknameAndIsDeletedFalse
            );
        } catch (IllegalStateException e) {
            log.error("Nickname generation failed after all fallbacks", e);
            throw new CustomException(ErrorCode.NICKNAME_GENERATION_FAILED, e);
        }
    }

    /**
     * 마지막 갱신 후 {@value #LAST_SEEN_THROTTLE_MINUTES}분이 지난 경우에만 갱신한다.
     * 동일 트랜잭션 내 dirty checking으로 UPDATE가 발생한다.
     */
    private void touchLastSeenIfStale(Member member) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime last = member.getLastSeenAt();
        if (last == null || last.plusMinutes(LAST_SEEN_THROTTLE_MINUTES).isBefore(now)) {
            member.setLastSeenAt(now);
        }
    }
}
