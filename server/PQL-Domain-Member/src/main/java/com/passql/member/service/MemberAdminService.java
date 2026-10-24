package com.passql.member.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.AdminRequestContext;
import com.passql.member.constant.MemberListSort;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.SuspendReasonCategory;
import com.passql.member.dto.MemberAdminDetailResponse;
import com.passql.member.dto.MemberAdminListResponse;
import com.passql.member.dto.MemberAdminSummaryResponse;
import com.passql.member.dto.MemberSearchCondition;
import com.passql.member.dto.MemberSuspendHistoryResponse;
import com.passql.member.entity.Member;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.entity.MemberSuspendHistory;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.MemberSpecification;
import com.passql.member.repository.MemberSuspendHistoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberAdminService {

    // 제재 사유 최대 길이 (member_suspend_history.reason 컬럼 길이)
    private static final int MAX_SUSPEND_REASON_LENGTH = 500;

    private final MemberRepository memberRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;
    private final MemberSuspendHistoryRepository suspendHistoryRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** self-injection: @Transactional(REQUIRES_NEW) 가 AOP 프록시를 거치게 하기 위함. */
    @Autowired
    @Lazy
    private MemberAdminService self;

    /** 회원 목록 검색: 필터(닉네임·UUID·상태·역할·기간·이용권) > 선택 정렬 > 페이지 > 프로 이용 여부 부착 */
    public Page<MemberAdminListResponse> searchMembers(MemberSearchCondition cond, Pageable pageable) {
        LocalDateTime now = LocalDateTime.now();
        Specification<Member> spec = Specification
            .where(MemberSpecification.notDeleted())
            .and(MemberSpecification.nicknameContains(cond.getNickname()))
            .and(MemberSpecification.memberUuidEquals(cond.getMemberUuid()))
            .and(MemberSpecification.statusEquals(cond.getStatus()))
            .and(MemberSpecification.roleEquals(cond.getRole()))
            .and(MemberSpecification.joinedAfter(cond.getJoinedFrom()))
            .and(MemberSpecification.joinedBefore(cond.getJoinedTo()))
            .and(MemberSpecification.lastSeenAfter(cond.getLastSeenFrom()))
            .and(MemberSpecification.lastSeenBefore(cond.getLastSeenTo()))
            .and(MemberSpecification.planMatches(cond.getPlanFilter(), now));

        if (!Boolean.TRUE.equals(cond.getIncludeTest())) {
            spec = spec.and(MemberSpecification.excludeTest());
        }

        // 접속순 정렬은 Specification 안에서 처리 (null 우선순위 때문)
        MemberListSort sortOption = cond.getSortOrDefault();
        if (sortOption == MemberListSort.RECENT_SEEN) {
            spec = spec.and(MemberSpecification.orderByLastSeen(false, true));
        } else if (sortOption == MemberListSort.OLDEST_SEEN) {
            spec = spec.and(MemberSpecification.orderByLastSeen(true, false));
        }

        Pageable sortedPageable = PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(),
            sortOption.toSort());
        Page<Member> memberPage = memberRepository.findAll(spec, sortedPageable);
        Set<UUID> proActiveMemberUuids = findProActiveMemberUuids(memberPage.getContent(), now);
        return memberPage.map(member -> MemberAdminListResponse.from(member,
            proActiveMemberUuids.contains(member.getMemberUuid())));
    }

    /** 목록 상단 요약: 상태별 회원 수 + 프로 이용 중 회원 수 (테스트 계정은 includeTest 일 때만 포함) */
    public MemberAdminSummaryResponse summarizeMembers(boolean includeTest) {
        Map<MemberStatus, Long> countByStatus = memberRepository.countGroupByStatusForAdmin(includeTest).stream()
            .collect(Collectors.toMap(row -> (MemberStatus) row[0], row -> (Long) row[1]));
        long activeCount = countByStatus.getOrDefault(MemberStatus.ACTIVE, 0L);
        long suspendedCount = countByStatus.getOrDefault(MemberStatus.SUSPENDED, 0L);
        long dormantCount = countByStatus.getOrDefault(MemberStatus.DORMANT, 0L);
        long withdrawnCount = countByStatus.getOrDefault(MemberStatus.WITHDRAWN, 0L);
        long totalCount = countByStatus.values().stream().mapToLong(Long::longValue).sum();
        return new MemberAdminSummaryResponse(totalCount, activeCount, suspendedCount, dormantCount, withdrawnCount,
            memberRepository.countProActiveForAdmin(includeTest, LocalDateTime.now()));
    }

    /** 이번 페이지 회원 중 프로 이용 중(만료 전 PRO)인 회원 */
    private Set<UUID> findProActiveMemberUuids(List<Member> members, LocalDateTime now) {
        List<UUID> memberUuids = members.stream().map(Member::getMemberUuid).toList();
        return memberEntitlementRepository.findAllById(memberUuids).stream()
            .filter(entitlement -> entitlement.getPlan() == MemberPlan.PRO
                && entitlement.getExpiresAt() != null && entitlement.getExpiresAt().isAfter(now))
            .map(MemberEntitlement::getMemberUuid)
            .collect(Collectors.toSet());
    }

    /** 회원 1명 목록 항목 (UUID 정확 일치, 탈퇴 회원 제외) — 전역 검색용 */
    public Optional<MemberAdminListResponse> findMemberListItem(UUID memberUuid) {
        return memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid).map(member -> {
            Set<UUID> proActiveMemberUuids = findProActiveMemberUuids(List.of(member), LocalDateTime.now());
            return MemberAdminListResponse.from(member, proActiveMemberUuids.contains(member.getMemberUuid()));
        });
    }

    /** 회원 상세 조회 */
    public MemberAdminDetailResponse getMemberDetail(UUID memberUuid) {
        Member member = memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberSuspendHistoryResponse> histories = suspendHistoryRepository
            .findAllByMemberUuidOrderByActedAtDesc(memberUuid)
            .stream()
            .map(MemberSuspendHistoryResponse::from)
            .toList();

        return MemberAdminDetailResponse.from(member, histories);
    }

    /** 회원 제재. suspendUntil은 null 불가, 과거 시각 불가, 사유 분류(선택)·사유 500자 이내. */
    @Transactional
    @CacheEvict(value = MemberSuspensionService.SUSPENSION_CACHE_NAME, key = "#memberUuid")
    public void suspendMember(UUID memberUuid, SuspendReasonCategory reasonCategory, String reason,
                              LocalDateTime suspendUntil) {
        if (suspendUntil == null || suspendUntil.isBefore(LocalDateTime.now())) {
            throw new CustomException(ErrorCode.INVALID_SUSPEND_UNTIL);
        }
        if (reason != null && reason.length() > MAX_SUSPEND_REASON_LENGTH) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "reason length > " + MAX_SUSPEND_REASON_LENGTH);
        }

        Member member = memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        member.setStatus(MemberStatus.SUSPENDED);
        member.setSuspendUntil(suspendUntil);

        suspendHistoryRepository.save(MemberSuspendHistory.ofSuspend(memberUuid, reasonCategory, reason, suspendUntil, AdminRequestContext.findAdminUsernameOrSystem()));
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.SUSPEND,
            null, AdminAuditEvent.summary("reasonCategory", reasonCategory, "reason", reason, "suspendUntil", suspendUntil)));
        log.info("Member suspended: uuid={}, until={}, reason={}", memberUuid, suspendUntil, reason);
    }

    /** 관리자 메모 저장 (공백만이면 삭제, 앱 미노출) */
    @Transactional
    public void updateAdminMemo(UUID memberUuid, String adminMemo) {
        if (adminMemo != null && adminMemo.length() > Member.MAX_ADMIN_MEMO_LENGTH) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "adminMemo length > " + Member.MAX_ADMIN_MEMO_LENGTH);
        }
        Member member = memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
        String previousMemo = member.getAdminMemo();
        member.setAdminMemo(adminMemo == null || adminMemo.isBlank() ? null : adminMemo.trim());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.UPDATE,
            AdminAuditEvent.summary("adminMemo", previousMemo), AdminAuditEvent.summary("adminMemo", member.getAdminMemo())));
    }

    /** 회원 제재 해제 (수동) */
    @Transactional
    @CacheEvict(value = MemberSuspensionService.SUSPENSION_CACHE_NAME, key = "#memberUuid")
    public void unsuspendMember(UUID memberUuid) {
        Member member = memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        member.setStatus(MemberStatus.ACTIVE);
        member.setSuspendUntil(null);

        suspendHistoryRepository.save(MemberSuspendHistory.ofUnsuspend(memberUuid, AdminRequestContext.findAdminUsernameOrSystem()));
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.UNSUSPEND));
        log.info("Member unsuspended (manual): uuid={}", memberUuid);
    }

    /**
     * 만료된 제재 자동 해제 (스케줄러에서 호출).
     * 조회는 readOnly TX, 건별 해제는 REQUIRES_NEW로 격리하여
     * 한 건 실패가 배치 전체를 롤백하지 않도록 한다.
     */
    public void autoUnsuspendExpired() {
        LocalDateTime now = LocalDateTime.now();
        List<UUID> expiredUuids = memberRepository
            .findAllByStatusAndSuspendUntilBeforeAndIsDeletedFalse(MemberStatus.SUSPENDED, now)
            .stream()
            .map(Member::getMemberUuid)
            .toList();

        int succeeded = 0;
        int failed = 0;
        for (UUID uuid : expiredUuids) {
            try {
                self.unsuspendSingleInNewTx(uuid);
                succeeded++;
            } catch (Exception e) {
                failed++;
                log.error("Auto-unsuspend failed for member: uuid={}", uuid, e);
            }
        }

        if (!expiredUuids.isEmpty()) {
            log.info("Auto-unsuspend batch: total={}, succeeded={}, failed={}",
                expiredUuids.size(), succeeded, failed);
        }
    }

    /** 단건 자동 해제 — 새 트랜잭션에서 실행되어 실패가 배치 전체를 오염시키지 않는다. */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void unsuspendSingleInNewTx(UUID memberUuid) {
        Member member = memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
        // 배치 조회 후 상태 변경됐을 수 있으므로 재확인
        if (member.getStatus() != MemberStatus.SUSPENDED) {
            return;
        }
        member.setStatus(MemberStatus.ACTIVE);
        member.setSuspendUntil(null);
        suspendHistoryRepository.save(MemberSuspendHistory.ofUnsuspend(memberUuid, AdminRequestContext.SYSTEM_ACTOR));
        log.info("Member auto-unsuspended: uuid={}", memberUuid);
    }
}
