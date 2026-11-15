package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.submission.constant.ExamAnswerItemStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * 가답안 문항 1개: 실제 번호·과목·출제 개념(직접 작성 한 줄)·운영 가답안 (#1075)
 * 회차 생성 시 50행 자동 생성
 */
@Entity
@Table(
    name = "exam_answer_item",
    uniqueConstraints = @UniqueConstraint(name = "uk_exam_answer_item_round_question", columnNames = {"exam_answer_round_uuid", "question_no"})
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ExamAnswerItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID examAnswerItemUuid;

    @Column(nullable = false)
    private UUID examAnswerRoundUuid;

    // 실제 문항 번호 (1~50)
    @Column(nullable = false)
    private Integer questionNo;

    // 과목: 1 (1~10번), 2 (11~50번)
    @Column(nullable = false)
    private Integer subjectNo;

    // 출제 개념 한 줄 (원문 아님, 운영자 작성)
    @Column(length = 200)
    private String conceptTitle;

    // 개념 태그 (쉼표 구분)
    @Column(length = 300)
    private String conceptTags;

    // 연결 토픽 코드 (topic.code, 없으면 null)
    @Column(length = 50)
    private String topicCode;

    // 운영 가답안 보기 번호 (1~4, 없으면 null)
    private Integer operatorAnswer;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ExamAnswerItemStatus operatorAnswerStatus = ExamAnswerItemStatus.UNKNOWN;

    // 복수 정답 인정 보기 (쉼표 구분, 예: "2,3", 없으면 null)
    @Column(length = 20)
    private String alternativeAnswers;

    // 갈림 이유 등 한 줄 메모 (공개)
    @Column(columnDefinition = "TEXT")
    private String note;
}
