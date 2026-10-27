package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.ConceptPublishStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(
    name = "concept_tag",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_concept_tag_key", columnNames = "tag_key")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ConceptTag extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID conceptTagUuid;

    @Column(nullable = false, length = 100)
    private String tagKey;

    @Column(length = 255)
    private String labelKo;

    @Column(length = 100)
    private String category;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private Boolean isActive = true;

    private Integer sortOrder;

    // 소속 단원 (topic, 개념 학습 화면 묶음 기준)
    private UUID topicUuid;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ConceptPublishStatus publishStatus = ConceptPublishStatus.DRAFT;

    // 목록에 보이는 한 줄 요약
    @Column(length = 255)
    private String summary;
}
