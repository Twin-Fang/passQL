package com.passql.member.repository;

import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberRepository extends JpaRepository<Member, UUID>, JpaSpecificationExecutor<Member> {

    // === 일반 조회 (소프트 딜리트 제외) ===
    Optional<Member> findByMemberUuidAndIsDeletedFalse(UUID memberUuid);

    boolean existsByMemberUuidAndIsDeletedFalse(UUID memberUuid);

    boolean existsByNicknameAndIsDeletedFalse(String nickname);

    Optional<Member> findByAuthProviderAndProviderUserIdAndIsDeletedFalse(
        AuthProvider authProvider, String providerUserId);

    // 같은 제공자 사용자 ID 활성 회원 존재 여부 (Firebase uid 는 Google·Apple 공용이라 제공자 여러 개로 확인)
    boolean existsByProviderUserIdAndAuthProviderInAndIsDeletedFalse(
        String providerUserId, Collection<AuthProvider> authProviders);

    /** 스케줄러용: 제재 만료 회원 배치 조회 */
    List<Member> findAllByStatusAndSuspendUntilBeforeAndIsDeletedFalse(
        MemberStatus status, LocalDateTime now);

    /** 알림 전체 발송 대상 수 — 탈퇴 제외 (팬아웃 INSERT 조건과 같게 유지) */
    long countByIsDeletedFalseAndStatusNot(MemberStatus status);

    /** 대시보드 집계용 — 테스트 계정 제외 전체 회원 수 */
    long countByIsTestAccountFalseAndIsDeletedFalse();

    /** 대시보드 집계용 — 테스트 계정 제외 상태별 회원 수 */
    long countByIsTestAccountFalseAndIsDeletedFalseAndStatus(MemberStatus status);
}
