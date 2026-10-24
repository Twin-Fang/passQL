package com.passql.member.repository;

import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.PushPlatform;
import com.passql.member.entity.Member;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 푸시 세그먼트 대상 회원 조회 5종: 프로, 무료, N일 미접속, 플랫폼별 기기 보유
 * 공통 조건: 삭제·탈퇴 제외 (알림함 전체 발송 대상과 같게, MemberNotificationRepository.insertForAllActiveMembers)
 */
public interface PushSegmentMemberRepository extends Repository<Member, UUID> {

    /** 프로: 등급 PRO 이고 만료 전 */
    @Query("""
            select m.memberUuid from Member m
            where m.isDeleted = false and m.status <> :withdrawn
              and exists (select 1 from MemberEntitlement e
                          where e.memberUuid = m.memberUuid and e.plan = :proPlan and e.expiresAt > :now)
            """)
    List<UUID> findProMemberUuids(@Param("withdrawn") MemberStatus withdrawn, @Param("proPlan") MemberPlan proPlan,
                                  @Param("now") LocalDateTime now);

    /** 무료: 프로가 아닌 회원 (등급 행 없음·FREE·만료 포함) */
    @Query("""
            select m.memberUuid from Member m
            where m.isDeleted = false and m.status <> :withdrawn
              and not exists (select 1 from MemberEntitlement e
                              where e.memberUuid = m.memberUuid and e.plan = :proPlan and e.expiresAt > :now)
            """)
    List<UUID> findFreeMemberUuids(@Param("withdrawn") MemberStatus withdrawn, @Param("proPlan") MemberPlan proPlan,
                                   @Param("now") LocalDateTime now);

    /** 미접속: 마지막 접속이 기준 시각 이전 */
    @Query("""
            select m.memberUuid from Member m
            where m.isDeleted = false and m.status <> :withdrawn and m.lastSeenAt < :cutoff
            """)
    List<UUID> findInactiveMemberUuids(@Param("withdrawn") MemberStatus withdrawn, @Param("cutoff") LocalDateTime cutoff);

    /** 플랫폼 기기 보유: 그 플랫폼의 수신 동의 토큰이 있는 회원 */
    @Query("""
            select distinct t.memberUuid from MemberPushToken t
            where t.platform = :platform and t.isPushEnabled = true
              and exists (select 1 from Member m where m.memberUuid = t.memberUuid
                          and m.isDeleted = false and m.status <> :withdrawn)
            """)
    List<UUID> findMemberUuidsWithPushDevice(@Param("withdrawn") MemberStatus withdrawn,
                                             @Param("platform") PushPlatform platform);
}
