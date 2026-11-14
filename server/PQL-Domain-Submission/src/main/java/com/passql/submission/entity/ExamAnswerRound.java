package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.CertType;
import com.passql.submission.constant.ExamAnswerRoundStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

/**
 * 실제 시험 회차별 가답안 (#1075): 자격증·회차 1개 = 1행, 문항 50개는 exam_answer_item
 * 원문 지문·보기는 저장하지 않음
 */
@Entity
@Table(
    name = "exam_answer_round",
    uniqueConstraints = @UniqueConstraint(name = "uk_exam_answer_round_cert_number", columnNames = {"cert_type", "round_number"})
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ExamAnswerRound extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID examAnswerRoundUuid;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CertType certType;

    // 실제 시험 회차 (제N회)
    @Column(nullable = false)
    private Integer roundNumber;

    @Column(nullable = false)
    private LocalDate examDate;

    @Column(nullable = false, length = 100)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ExamAnswerRoundStatus status = ExamAnswerRoundStatus.COLLECTING;

    // 사이트·앱 상단 안내 (면책·공식 발표 일정 등, 없으면 null)
    @Column(columnDefinition = "TEXT")
    private String notice;
}
