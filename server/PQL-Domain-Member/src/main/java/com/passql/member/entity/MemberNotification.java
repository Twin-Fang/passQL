package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 한 명이 받은 일반 알림 한 건 (알림함 '알림' 탭)
 * 안 읽은 개수용 부분 인덱스(idx_member_notification_unread)는 Flyway 에서만 생성
 */
@Entity
@Table(
    name = "member_notification",
    indexes = {
        @Index(name = "idx_member_notification_member_created", columnList = "member_uuid, created_at, member_notification_uuid"),
        @Index(name = "idx_member_notification_history", columnList = "push_send_history_uuid"),
        @Index(name = "idx_member_notification_created_at", columnList = "created_at")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberNotification extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID memberNotificationUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private MemberNotificationType notificationType;

    @Column(length = PushSendHistory.MAX_TITLE_LENGTH, nullable = false)
    private String title;

    @Column(length = PushSendHistory.MAX_BODY_LENGTH, nullable = false)
    private String body;

    // 탭하면 이동할 화면 (푸시 허용 목록과 같은 값)
    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private PushLinkTarget linkTarget;

    // linkTarget QUESTION_DETAIL 일 때만 값
    private UUID linkQuestionUuid;

    // 관리자 발송에서 생긴 경우 원본 발송 (그 외 null)
    private UUID pushSendHistoryUuid;

    // 읽은 시각 (null = 안 읽음)
    private LocalDateTime readAt;

    // 관리자가 발송을 회수하면 true (목록·개수에서 제외)
    @Column(nullable = false)
    private Boolean isHidden;

    /** 알림 1건 (안 읽음, 노출 중) */
    public static MemberNotification create(UUID memberUuid, MemberNotificationType notificationType,
                                            String title, String body, PushLinkTarget linkTarget,
                                            UUID linkQuestionUuid, UUID pushSendHistoryUuid) {
        MemberNotification notification = new MemberNotification();
        notification.memberUuid = memberUuid;
        notification.notificationType = notificationType;
        notification.title = title;
        notification.body = body;
        notification.linkTarget = linkTarget;
        notification.linkQuestionUuid = linkQuestionUuid;
        notification.pushSendHistoryUuid = pushSendHistoryUuid;
        notification.isHidden = false;
        return notification;
    }

    public boolean isRead() {
        return readAt != null;
    }
}
