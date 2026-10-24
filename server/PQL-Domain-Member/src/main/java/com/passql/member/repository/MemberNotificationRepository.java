package com.passql.member.repository;

import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.entity.MemberNotification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

/** 일반 알림 저장소: 사용은 알림 서비스 2개만 (ArchitectureRuleTest) */
public interface MemberNotificationRepository extends JpaRepository<MemberNotification, UUID> {

    /** 목록 첫 페이지: 최신순 (숨김 제외) */
    @Query("select n from MemberNotification n where n.memberUuid = :memberUuid and n.isHidden = false "
            + "order by n.createdAt desc, n.memberNotificationUuid desc")
    List<MemberNotification> findFirstPage(@Param("memberUuid") UUID memberUuid, Pageable pageable);

    /** 목록 다음 페이지: 커서(createdAt, uuid) 보다 오래된 것 (OFFSET 없음) */
    @Query("select n from MemberNotification n where n.memberUuid = :memberUuid and n.isHidden = false "
            + "and (n.createdAt < :cursorCreatedAt or (n.createdAt = :cursorCreatedAt and n.memberNotificationUuid < :cursorUuid)) "
            + "order by n.createdAt desc, n.memberNotificationUuid desc")
    List<MemberNotification> findNextPage(@Param("memberUuid") UUID memberUuid,
                                          @Param("cursorCreatedAt") LocalDateTime cursorCreatedAt,
                                          @Param("cursorUuid") UUID cursorUuid, Pageable pageable);

    /** 안 읽은 개수 (부분 인덱스 조건과 같음) */
    long countByMemberUuidAndReadAtIsNullAndIsHiddenFalse(UUID memberUuid);

    /** 회원별 안 읽은 개수 (푸시 배지용, 대상 회원만) */
    @Query("select n.memberUuid as keyUuid, count(n) as rowCount from MemberNotification n "
            + "where n.readAt is null and n.isHidden = false and n.memberUuid in :memberUuids group by n.memberUuid")
    List<UuidCountProjection> countUnreadGroupedByMember(@Param("memberUuids") Collection<UUID> memberUuids);

    /** 회원별 안 읽은 개수 (전체 발송 푸시 배지용, GROUP BY 1회) */
    @Query("select n.memberUuid as keyUuid, count(n) as rowCount from MemberNotification n "
            + "where n.readAt is null and n.isHidden = false group by n.memberUuid")
    List<UuidCountProjection> countUnreadGroupedByAllMembers();

    /** 1건 읽음 (본인 알림만, 이미 읽은 건 그대로) > 바뀐 행 수 */
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update MemberNotification n set n.readAt = :readAt "
            + "where n.memberNotificationUuid = :notificationUuid and n.memberUuid = :memberUuid "
            + "and n.readAt is null and n.isHidden = false")
    int markRead(@Param("memberUuid") UUID memberUuid, @Param("notificationUuid") UUID notificationUuid,
                 @Param("readAt") LocalDateTime readAt);

    /** 모두 읽음 > 바뀐 행 수 */
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update MemberNotification n set n.readAt = :readAt "
            + "where n.memberUuid = :memberUuid and n.readAt is null and n.isHidden = false")
    int markAllRead(@Param("memberUuid") UUID memberUuid, @Param("readAt") LocalDateTime readAt);

    /** 발송 회수: 그 발송에서 생긴 알림 숨김 > 숨긴 행 수 */
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update MemberNotification n set n.isHidden = true "
            + "where n.pushSendHistoryUuid = :pushSendHistoryUuid and n.isHidden = false")
    int hideByPushSendHistory(@Param("pushSendHistoryUuid") UUID pushSendHistoryUuid);

    /** 발송별 받은 회원 수·읽은 수 (관리자 이력, 발송 UUID 인덱스) */
    @Query("select n.pushSendHistoryUuid as pushSendHistoryUuid, count(n) as recipientCount, count(n.readAt) as readCount "
            + "from MemberNotification n where n.pushSendHistoryUuid in :pushSendHistoryUuids group by n.pushSendHistoryUuid")
    List<NotificationReadStatProjection> summarizeReadByPushSendHistory(
            @Param("pushSendHistoryUuids") Collection<UUID> pushSendHistoryUuids);

    /** 관리자 회원 상세: 그 회원의 최근 알림 (숨김 포함) */
    List<MemberNotification> findByMemberUuidOrderByCreatedAtDesc(UUID memberUuid, Pageable pageable);

    /** 관리자 회원 상세: 그 회원의 알림 한 페이지 (숨김 포함) */
    Page<MemberNotification> findPageByMemberUuidOrderByCreatedAtDesc(UUID memberUuid, Pageable pageable);

    /**
     * 전체 회원에게 같은 알림 1건씩 INSERT ... SELECT (탈퇴 제외) > 만든 행 수
     * 회원 1,000명 단위 반복 대신 SQL 한 번 (대상 조건은 MemberRepository.countByIsDeletedFalseAndStatusNot 과 같게)
     */
    @Modifying
    @Query(value = """
            INSERT INTO member_notification (member_notification_uuid, member_uuid, notification_type, title, body,
                                             link_target, link_question_uuid, push_send_history_uuid, is_hidden,
                                             created_at, updated_at, created_by, updated_by)
            SELECT gen_random_uuid(), m.member_uuid, :#{#notificationType.name()}, :title, :body,
                   :#{#linkTarget.name()}, CAST(:linkQuestionUuid AS uuid), CAST(:pushSendHistoryUuid AS uuid), FALSE,
                   :createdAt, :createdAt, 'system', 'system'
            FROM member m
            WHERE m.is_deleted = FALSE AND m.status <> 'WITHDRAWN'
            """, nativeQuery = true)
    int insertForAllActiveMembers(@Param("notificationType") MemberNotificationType notificationType,
                                  @Param("title") String title, @Param("body") String body,
                                  @Param("linkTarget") PushLinkTarget linkTarget,
                                  @Param("linkQuestionUuid") UUID linkQuestionUuid,
                                  @Param("pushSendHistoryUuid") UUID pushSendHistoryUuid,
                                  @Param("createdAt") LocalDateTime createdAt);

    /** 보관 기간 지난 알림 묶음 삭제 (createdAt 인덱스, 한 번에 batchSize 건) > 지운 행 수 */
    @Modifying
    @Query(value = """
            DELETE FROM member_notification WHERE member_notification_uuid IN (
                SELECT member_notification_uuid FROM member_notification WHERE created_at < :cutoff LIMIT :batchSize)
            """, nativeQuery = true)
    int deleteExpiredBatch(@Param("cutoff") LocalDateTime cutoff, @Param("batchSize") int batchSize);
}
