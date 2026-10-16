package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.ChoiceKind;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

/**
 * QuestionChoiceSet 내 개별 선택지 (A~D).
 * 샌드박스 실행 결과는 sandboxExecutionJson 에 JSON 으로 기록 (생성 시점 검증 이력).
 */
@Entity
@Table(
    name = "question_choice_set_item",
    uniqueConstraints = {
        @UniqueConstraint(
            name = "uk_choice_set_item_key",
            columnNames = {"choice_set_uuid", "choice_key"}
        )
    },
    indexes = {
        @Index(name = "idx_choice_set_item_set", columnList = "choice_set_uuid")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class QuestionChoiceSetItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID choiceSetItemUuid;

    @Column(nullable = false)
    private UUID choiceSetUuid;

    @Column(length = 8, nullable = false)
    private String choiceKey;

    @Column(nullable = false)
    private Integer sortOrder;

    @Enumerated(EnumType.STRING)
    @Column(length = 10, nullable = false)
    @Builder.Default
    private ChoiceKind kind = ChoiceKind.SQL;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String body;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isCorrect = false;

    @Column(columnDefinition = "TEXT")
    private String rationale;

    // 이 선택지를 골랐을 때의 AI 해설 (세트 저장 직후 미리 생성, 없으면 첫 요청 때 생성) (#496)
    @Column(columnDefinition = "TEXT")
    private String explanation;

    // 해설을 만든 diff_explain 프롬프트 버전 (활성 버전과 다르면 다시 생성)
    private Integer explanationPromptVersion;

    @JdbcTypeCode(SqlTypes.JSON)  // Hibernate 6 + PostgreSQL jsonb 컬럼 호환
    @Column(columnDefinition = "JSONB")
    private String sandboxExecutionJson;
}
