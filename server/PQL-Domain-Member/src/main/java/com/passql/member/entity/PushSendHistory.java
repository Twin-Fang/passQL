package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.NotificationDeliveryMode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushDispatchStatus;
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
 * 관리자 발송 이력: 내용, 대상, 전달 방식, 이동 경로, 결과 수, 발송 관리자, 회수 여부, 예약·테스트 여부
 * 결과 수는 발송 접수 때 0, 알림함 저장·푸시 전달이 끝나면 갱신 / 예약 발송은 sentAt = 예약 시각으로 두고 발송 시작 때 현재 시각으로 갱신
 */
@Entity
@Table(
    name = "push_send_history",
    indexes = {
        @Index(name = "idx_push_send_history_sent_at", columnList = "sent_at"),
        @Index(name = "idx_push_send_history_schedule", columnList = "dispatch_status, scheduled_at")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PushSendHistory extends BaseEntity {

    // 제목·본문 최대 길이 (문자 수)
    public static final int MAX_TITLE_LENGTH = 100;
    public static final int MAX_BODY_LENGTH = 500;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID pushSendHistoryUuid;

    @Column(length = MAX_TITLE_LENGTH, nullable = false)
    private String title;

    @Column(length = MAX_BODY_LENGTH, nullable = false)
    private String body;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private PushAudience audience;

    // audience MEMBER 일 때만 값
    private UUID targetMemberUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private PushLinkTarget linkTarget;

    // linkTarget QUESTION_DETAIL 일 때만 값
    private UUID linkQuestionUuid;

    // 발송 시도 기기 수, 성공·실패 수, 만료로 삭제한 토큰 수
    @Column(nullable = false)
    private Integer targetDeviceCount;

    @Column(nullable = false)
    private Integer successCount;

    @Column(nullable = false)
    private Integer failureCount;

    @Column(nullable = false)
    private Integer removedTokenCount;

    // audience INACTIVE_MEMBERS 일 때만 값: 이 일수 이상 미접속
    private Integer inactiveDays;

    // 예약 발송 시각 (즉시 발송이면 null, KST)
    private LocalDateTime scheduledAt;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private PushDispatchStatus dispatchStatus;

    // 테스트 발송 (통계·읽음률 집계에서 제외)
    @Column(nullable = false)
    private Boolean isTest;

    // 발송 관리자 로그인 아이디
    @Column(length = 100, nullable = false)
    private String sentByAdmin;

    @Column(nullable = false)
    private LocalDateTime sentAt;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private NotificationDeliveryMode deliveryMode;

    // 알림함에 만든 행 수 (받은 회원 수)
    @Column(nullable = false)
    private Integer recipientCount;

    // 관리자가 회수하면 true (알림함에서 숨김)
    @Column(nullable = false)
    private Boolean isRetracted;

    private LocalDateTime retractedAt;

    @Column(length = 100)
    private String retractedBy;

    /** 즉시 발송 접수 (세그먼트·예약·테스트 없음) */
    public static PushSendHistory accept(String title, String body, PushAudience audience, UUID targetMemberUuid,
                                         PushLinkTarget linkTarget, UUID linkQuestionUuid,
                                         NotificationDeliveryMode deliveryMode, String sentByAdmin) {
        return accept(title, body, audience, targetMemberUuid, null, linkTarget, linkQuestionUuid,
                deliveryMode, sentByAdmin, null, false);
    }

    /** 발송 접수: 결과 수는 0 으로 시작, scheduledAt 있으면 예약 대기 */
    public static PushSendHistory accept(String title, String body, PushAudience audience, UUID targetMemberUuid,
                                         Integer inactiveDays, PushLinkTarget linkTarget, UUID linkQuestionUuid,
                                         NotificationDeliveryMode deliveryMode, String sentByAdmin,
                                         LocalDateTime scheduledAt, boolean isTest) {
        PushSendHistory history = new PushSendHistory();
        history.inactiveDays = inactiveDays;
        history.scheduledAt = scheduledAt;
        history.dispatchStatus = scheduledAt == null ? PushDispatchStatus.DISPATCHED : PushDispatchStatus.SCHEDULED;
        history.isTest = isTest;
        history.title = title;
        history.body = body;
        history.audience = audience;
        history.targetMemberUuid = targetMemberUuid;
        history.linkTarget = linkTarget;
        history.linkQuestionUuid = linkQuestionUuid;
        history.deliveryMode = deliveryMode;
        history.targetDeviceCount = 0;
        history.successCount = 0;
        history.failureCount = 0;
        history.removedTokenCount = 0;
        history.recipientCount = 0;
        history.isRetracted = false;
        history.sentByAdmin = sentByAdmin;
        history.sentAt = scheduledAt == null ? LocalDateTime.now() : scheduledAt;
        return history;
    }

    /** 예약 대기 중이면 true */
    public boolean isScheduled() {
        return dispatchStatus == PushDispatchStatus.SCHEDULED;
    }

    /** 알림함에 만든 행 수 기록 */
    public void recordRecipientCount(int recipientCount) {
        this.recipientCount = recipientCount;
    }

    /** 푸시 전달 결과 기록 */
    public void recordDeliveryResult(int targetDeviceCount, int successCount, int failureCount, int removedTokenCount) {
        this.targetDeviceCount = targetDeviceCount;
        this.successCount = successCount;
        this.failureCount = failureCount;
        this.removedTokenCount = removedTokenCount;
    }

    /** 회수 처리 (알림함 숨김은 알림 쪽에서 처리) */
    public void retract(String retractedByAdmin) {
        this.isRetracted = true;
        this.retractedAt = LocalDateTime.now();
        this.retractedBy = retractedByAdmin;
    }
}
