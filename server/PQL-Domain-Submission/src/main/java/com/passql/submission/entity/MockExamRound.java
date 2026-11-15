package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamRoundType;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 모의고사 회차: 관리자가 구성·공개하는 고정 시험지 (#866), 종류 2개 모의고사·기출 복원 (#1079)
 * 공개 뒤 문항은 고정, 보관하면 사용자 목록에서만 빠짐
 */
@Entity
@Table(
    name = "mock_exam_round",
    uniqueConstraints = @UniqueConstraint(name = "uk_mock_exam_round_type_number", columnNames = {"round_type", "round_number"}),
    indexes = @Index(name = "idx_mock_exam_round_status", columnList = "status")
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class MockExamRound extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID mockExamRoundUuid;

    // 회차 번호 (종류별 유일): MOCK 제N회(무료 체험 회차 판정 기준), PAST_EXAM 실제 시험 회차 (예 62)
    @Column(nullable = false)
    private Integer roundNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private MockExamRoundType roundType = MockExamRoundType.MOCK;

    // 실제 시험일 (PAST_EXAM 만, MOCK 은 null)
    private LocalDate examDate;

    @Column(nullable = false, length = 100)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private MockExamRoundStatus status = MockExamRoundStatus.DRAFT;

    private LocalDateTime publishedAt;

    public boolean isPastExam() {
        return roundType == MockExamRoundType.PAST_EXAM;
    }

    /** 실제 시험 회차 번호 (PAST_EXAM 만, MOCK 은 null) */
    public Integer getExamRoundNumberOrNull() {
        return isPastExam() ? roundNumber : null;
    }
}
