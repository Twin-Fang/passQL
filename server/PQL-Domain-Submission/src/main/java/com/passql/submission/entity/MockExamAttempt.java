package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamSubmitReason;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 모의고사 응시 1회: 시작·마감 시각(서버 KST), 채점 결과 고정 저장
 * 채점 결과는 채점 시점 값 그대로 (규칙이 바뀌어도 지난 점수 유지, 추이·통계 조회 가벼움)
 */
@Entity
@Table(
    name = "mock_exam_attempt",
    indexes = {
        @Index(name = "idx_mock_exam_attempt_member_status", columnList = "member_uuid, status"),
        @Index(name = "idx_mock_exam_attempt_member_round", columnList = "member_uuid, mock_exam_round_uuid"),
        @Index(name = "idx_mock_exam_attempt_round_status", columnList = "mock_exam_round_uuid, status"),
        @Index(name = "idx_mock_exam_attempt_status_deadline", columnList = "status, deadline_at")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class MockExamAttempt extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID mockExamAttemptUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(nullable = false)
    private UUID mockExamRoundUuid;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private MockExamAttemptStatus status = MockExamAttemptStatus.IN_PROGRESS;

    @Column(nullable = false)
    private LocalDateTime startedAt;

    // 시작 + 90분 (남은 시간·자동 제출 기준)
    @Column(nullable = false)
    private LocalDateTime deadlineAt;

    private LocalDateTime submittedAt;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private MockExamSubmitReason submitReason;

    private Integer correctCount;

    private Integer subjectOneCorrectCount;

    private Integer subjectTwoCorrectCount;

    private Integer totalScore;

    private Boolean isPassed;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private MockExamFailReason failReason;

    public boolean isInProgress() {
        return status == MockExamAttemptStatus.IN_PROGRESS;
    }
}
