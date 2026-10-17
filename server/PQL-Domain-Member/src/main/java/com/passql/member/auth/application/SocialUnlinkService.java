package com.passql.member.auth.application;

import com.passql.member.auth.domain.ProviderTokens;
import com.passql.member.auth.infrastructure.social.unlink.SocialUnlinkClient;
import com.passql.member.constant.AuthProvider;
import com.passql.member.event.MemberWithdrawnEvent;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberSocialCredentialService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Optional;
import java.util.Set;

/**
 * 탈퇴 커밋 후 제공자 연결 해제 (#516): 제공자별 해제 > 저장 자격 삭제
 * 전용 실행기에서 비동기 실행, 실패는 로그만 (탈퇴는 이미 확정)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SocialUnlinkService {

    // AsyncConfig 에 등록하는 실행기 이름
    public static final String EXECUTOR_NAME = "socialUnlinkTaskExecutor";
    // Firebase 사용자(uid)를 쓰는 제공자 2개
    private static final Set<AuthProvider> FIREBASE_PROVIDERS = Set.of(AuthProvider.GOOGLE, AuthProvider.APPLE);

    private final SocialUnlinkClient socialUnlinkClient;
    private final MemberSocialCredentialService memberSocialCredentialService;
    private final MemberRepository memberRepository;

    /** 제공자별 해제 > 자격 삭제 (성공·실패 공통) */
    @Async(EXECUTOR_NAME)
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onMemberWithdrawn(MemberWithdrawnEvent event) {
        try {
            if (unlinkProvider(event)) {
                log.info("[social unlink] ok provider={} memberUuid={}", event.authProvider(), event.memberUuid());
            }
        } catch (RuntimeException e) {
            log.warn("[social unlink] failed provider={} memberUuid={} : {} {}",
                    event.authProvider(), event.memberUuid(), e.getClass().getSimpleName(), e.getMessage());
        } finally {
            deleteCredentialQuietly(event);
        }
    }

    /** 제공자별 해제 호출 (해제 수단 없으면 false) */
    private boolean unlinkProvider(MemberWithdrawnEvent event) {
        switch (event.authProvider()) {
            case KAKAO -> socialUnlinkClient.unlinkKakaoUser(event.providerUserId());
            case GOOGLE, APPLE -> {
                if (hasRejoinedWithSameFirebaseUser(event)) {
                    return false;
                }
                socialUnlinkClient.deleteFirebaseUser(event.providerUserId());
            }
            case GITHUB -> {
                Optional<ProviderTokens> tokens = findStoredTokens(event);
                if (tokens.isEmpty()) {
                    return false;
                }
                socialUnlinkClient.revokeGithubGrant(tokens.get().accessToken());
            }
            case NAVER -> {
                Optional<ProviderTokens> tokens = findStoredTokens(event);
                if (tokens.isEmpty()) {
                    return false;
                }
                socialUnlinkClient.deleteNaverToken(tokens.get());
            }
        }
        return true;
    }

    /** 탈퇴 직후 같은 uid 로 재가입한 활성 회원 있으면 Firebase 사용자 유지 (지우면 새 회원 로그인 끊김) */
    private boolean hasRejoinedWithSameFirebaseUser(MemberWithdrawnEvent event) {
        boolean hasRejoined = memberRepository.existsByProviderUserIdAndAuthProviderInAndIsDeletedFalse(
                event.providerUserId(), FIREBASE_PROVIDERS);
        if (hasRejoined) {
            log.warn("[social unlink] skipped provider={} memberUuid={} : active member uses same firebase uid",
                    event.authProvider(), event.memberUuid());
        }
        return hasRejoined;
    }

    /** 저장 자격 조회 (없으면 건너뜀 로그, 예: 기능 배포 전 마지막 로그인) */
    private Optional<ProviderTokens> findStoredTokens(MemberWithdrawnEvent event) {
        Optional<ProviderTokens> tokens = memberSocialCredentialService.findTokens(event.memberUuid());
        if (tokens.isEmpty()) {
            log.warn("[social unlink] skipped provider={} memberUuid={} : no stored credential",
                    event.authProvider(), event.memberUuid());
        }
        return tokens;
    }

    private void deleteCredentialQuietly(MemberWithdrawnEvent event) {
        try {
            memberSocialCredentialService.deleteByMemberUuid(event.memberUuid());
        } catch (RuntimeException e) {
            log.warn("[social unlink] credential delete failed memberUuid={} : {}", event.memberUuid(), e.getClass().getSimpleName());
        }
    }
}
