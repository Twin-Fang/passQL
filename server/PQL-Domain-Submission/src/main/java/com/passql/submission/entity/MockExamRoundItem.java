package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.passql.submission.constant.MockExamSubject;

import java.util.UUID;

/**
 * 회차 문항: 문제 + 고정 보기 세트 (모든 응시자가 같은 보기, 문항 통계 비교 기준)
 * 토픽·과목은 구성 시점 값 고정 (문제 토픽이 바뀌어도 지난 회차 채점 유지)
 */
@Entity
@Table(
    name = "mock_exam_round_item",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_mock_exam_item_number", columnNames = {"mock_exam_round_uuid", "question_number"}),
        @UniqueConstraint(name = "uk_mock_exam_item_question", columnNames = {"mock_exam_round_uuid", "question_uuid"})
    },
    indexes = @Index(name = "idx_mock_exam_item_question", columnList = "question_uuid")
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class MockExamRoundItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID mockExamRoundItemUuid;

    @Column(nullable = false)
    private UUID mockExamRoundUuid;

    // 문항 번호 (1과목 1~10, 2과목 11~50)
    @Column(nullable = false)
    private Integer questionNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private MockExamSubject subject;

    @Column(nullable = false)
    private UUID topicUuid;

    @Column(nullable = false)
    private UUID questionUuid;

    @Column(nullable = false)
    private UUID choiceSetUuid;
}
