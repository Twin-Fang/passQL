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
 * 개념 확인 문제: 개념 하나만 묻는 쉬운 문제 (개념당 5개, 기존 문제 풀과 분리)
 * 풀이의 "다시 읽기"는 reread_anchor 가 가리키는 자세히 문단으로 이동
 */
@Entity
@Table(
    name = "concept_check_question",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_concept_check_question_order", columnNames = {"concept_tag_uuid", "sort_order"})
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ConceptCheckQuestion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID conceptCheckQuestionUuid;

    @Column(nullable = false)
    private UUID conceptTagUuid;

    // 개념 안 출제 순서 (1~5, 쉬운 것부터)
    @Column(nullable = false)
    private Integer sortOrder;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String stem;

    // 지문에 딸린 SQL (없으면 null, 표시 전용)
    @Column(columnDefinition = "TEXT")
    private String stemSql;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String explanation;

    // 자세히 문단 앵커 (예: confusing)
    @Column(nullable = false, length = 80)
    private String rereadAnchor;
}
