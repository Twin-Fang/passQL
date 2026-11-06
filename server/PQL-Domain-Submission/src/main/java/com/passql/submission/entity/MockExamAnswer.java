package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 응시 문항 답: 고른 보기·표시 여부 (문항마다 바로 저장, 이어 풀기 원본), 채점 뒤 정오
 */
@Entity
@Table(
    name = "mock_exam_answer",
    uniqueConstraints = @UniqueConstraint(name = "uk_mock_exam_answer_item",
        columnNames = {"mock_exam_attempt_uuid", "mock_exam_round_item_uuid"}),
    indexes = @Index(name = "idx_mock_exam_answer_item", columnList = "mock_exam_round_item_uuid")
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class MockExamAnswer extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID mockExamAnswerUuid;

    @Column(nullable = false)
    private UUID mockExamAttemptUuid;

    @Column(nullable = false)
    private UUID mockExamRoundItemUuid;

    @Column(nullable = false)
    private Integer questionNumber;

    // 고른 보기 키 (null: 안 고름·선택 해제)
    @Column(length = 8)
    private String selectedChoiceKey;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isFlagged = false;

    // 채점 뒤 정오 (풀이 중 null)
    private Boolean isCorrect;

    private LocalDateTime answeredAt;
}
