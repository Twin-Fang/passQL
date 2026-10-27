package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * 개념 확인 문제 보기: 고정 보기 4개 중 정답 1개
 */
@Entity
@Table(
    name = "concept_check_choice",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_concept_check_choice_key", columnNames = {"concept_check_question_uuid", "choice_key"})
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ConceptCheckChoice extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID conceptCheckChoiceUuid;

    @Column(nullable = false)
    private UUID conceptCheckQuestionUuid;

    // 보기 키 (A~D)
    @Column(nullable = false, length = 4)
    private String choiceKey;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(nullable = false)
    private Boolean isCorrect;

    // 이 보기가 맞거나 틀린 이유 (없으면 null)
    @Column(columnDefinition = "TEXT")
    private String rationale;

    @Column(nullable = false)
    private Integer sortOrder;
}
