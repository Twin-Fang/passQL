package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.FeedbackStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
    name = "feedback",
    indexes = {
        @Index(name = "idx_feedback_member_uuid", columnList = "member_uuid"),
        @Index(name = "idx_feedback_created_at", columnList = "created_at")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Feedback extends BaseEntity {

    // 답변 최대 길이 (문자 수, 알림 본문 한도와 같음)
    public static final int MAX_REPLY_LENGTH = 500;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID feedbackUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(nullable = false, length = 500)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private FeedbackStatus status;

    // 관리자 메모 (답변·처리 내용, 앱 미노출, 최대 1000자, #479)
    @Column(length = 1000)
    private String adminMemo;

    // 회원에게 보낸 답변 (알림함 전달본, 없으면 null)
    @Column(length = MAX_REPLY_LENGTH)
    private String replyMessage;

    private LocalDateTime repliedAt;
}
