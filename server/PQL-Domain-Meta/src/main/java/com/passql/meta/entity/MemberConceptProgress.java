package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.ConceptReadingDepth;
import com.passql.meta.constant.ConceptStudyMode;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * 회원별 개념 진행: 읽음 여부, 마지막 모드·깊이, 확인 문제 정답 수
 * 정답 수·푼 수는 문제별 마지막 답(answered_choice_keys_json) 기준
 */
@Entity
@Table(
    name = "member_concept_progress",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_member_concept_progress", columnNames = {"member_uuid", "concept_tag_uuid"})
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class MemberConceptProgress extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID memberConceptProgressUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(nullable = false)
    private UUID conceptTagUuid;

    @Builder.Default
    @Column(nullable = false)
    private Boolean isRead = false;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ConceptStudyMode lastMode = ConceptStudyMode.READ;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ConceptReadingDepth lastDepth = ConceptReadingDepth.CORE;

    @Builder.Default
    @Column(nullable = false)
    private Integer checkCorrectCount = 0;

    @Builder.Default
    @Column(nullable = false)
    private Integer checkSolvedCount = 0;

    // 확인 문제 UUID > 마지막 선택 키 JSON (예: {"uuid":"A"})
    @Builder.Default
    @Column(nullable = false, columnDefinition = "TEXT")
    private String answeredChoiceKeysJson = "{}";
}
