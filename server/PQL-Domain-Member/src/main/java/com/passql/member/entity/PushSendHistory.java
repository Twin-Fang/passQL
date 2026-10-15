package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.PushAudience;
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
 * 관리자 푸시 발송 이력: 내용, 대상, 이동 경로, 결과 수, 발송 관리자
 */
@Entity
@Table(
    name = "push_send_history",
    indexes = @Index(name = "idx_push_send_history_sent_at", columnList = "sent_at")
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

    // 발송 관리자 로그인 아이디
    @Column(length = 100, nullable = false)
    private String sentByAdmin;

    @Column(nullable = false)
    private LocalDateTime sentAt;

    public static PushSendHistory of(String title, String body, PushAudience audience, UUID targetMemberUuid,
                                     PushLinkTarget linkTarget, UUID linkQuestionUuid,
                                     int targetDeviceCount, int successCount, int failureCount,
                                     int removedTokenCount, String sentByAdmin) {
        PushSendHistory history = new PushSendHistory();
        history.title = title;
        history.body = body;
        history.audience = audience;
        history.targetMemberUuid = targetMemberUuid;
        history.linkTarget = linkTarget;
        history.linkQuestionUuid = linkQuestionUuid;
        history.targetDeviceCount = targetDeviceCount;
        history.successCount = successCount;
        history.failureCount = failureCount;
        history.removedTokenCount = removedTokenCount;
        history.sentByAdmin = sentByAdmin;
        history.sentAt = LocalDateTime.now();
        return history;
    }
}
