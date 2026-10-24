package com.passql.member.repository;

import com.passql.member.entity.MemberNoticeRead;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/** 공지 읽음: 사용은 알림 서비스 2개만 (ArchitectureRuleTest) */
public interface MemberNoticeReadRepository extends JpaRepository<MemberNoticeRead, MemberNoticeRead.Key> {

    /** 회원이 읽은 공지 UUID (후보 공지 중) */
    @Query("select r.appNoticeUuid from MemberNoticeRead r where r.memberUuid = :memberUuid and r.appNoticeUuid in :noticeUuids")
    Set<UUID> findReadNoticeUuids(@Param("memberUuid") UUID memberUuid, @Param("noticeUuids") Collection<UUID> noticeUuids);

    /** 읽음 기록 (이미 있으면 무시, 동시 요청에도 안전) */
    @Modifying
    @Query(value = """
            INSERT INTO member_notice_read (member_uuid, app_notice_uuid, read_at)
            VALUES (:memberUuid, :noticeUuid, :readAt)
            ON CONFLICT (member_uuid, app_notice_uuid) DO NOTHING
            """, nativeQuery = true)
    int insertIfAbsent(@Param("memberUuid") UUID memberUuid, @Param("noticeUuid") UUID noticeUuid,
                       @Param("readAt") LocalDateTime readAt);

    /** 회원별 읽은 공지 수 (후보 공지 중, 전체 발송 푸시 배지용 GROUP BY 1회) */
    @Query("select r.memberUuid as keyUuid, count(r) as rowCount from MemberNoticeRead r "
            + "where r.appNoticeUuid in :noticeUuids group by r.memberUuid")
    List<UuidCountProjection> countReadGroupedByMember(@Param("noticeUuids") Collection<UUID> noticeUuids);

    /** 회원별 읽은 공지 수 (대상 회원만) */
    @Query("select r.memberUuid as keyUuid, count(r) as rowCount from MemberNoticeRead r "
            + "where r.memberUuid in :memberUuids and r.appNoticeUuid in :noticeUuids group by r.memberUuid")
    List<UuidCountProjection> countReadGroupedByMember(@Param("memberUuids") Collection<UUID> memberUuids,
                                                       @Param("noticeUuids") Collection<UUID> noticeUuids);

    /** 공지 삭제 시 그 공지의 읽음 기록 정리 > 지운 행 수 */
    @Modifying
    @Query("delete from MemberNoticeRead r where r.appNoticeUuid = :noticeUuid")
    int deleteAllByAppNoticeUuid(@Param("noticeUuid") UUID noticeUuid);

    /** 공지별 읽은 회원 수 (관리자 공지 목록) */
    @Query("select r.appNoticeUuid as keyUuid, count(r) as rowCount from MemberNoticeRead r "
            + "where r.appNoticeUuid in :noticeUuids group by r.appNoticeUuid")
    List<UuidCountProjection> countReadMembersGroupedByNotice(@Param("noticeUuids") Collection<UUID> noticeUuids);
}
