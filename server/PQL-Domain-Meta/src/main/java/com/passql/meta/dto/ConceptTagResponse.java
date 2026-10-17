package com.passql.meta.dto;

import com.passql.meta.entity.ConceptTag;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 공개 개념 태그 응답: 식별자·키·표시 이름·분류·설명·정렬 순서
 * 감사 필드(createdAt·updatedAt·createdBy·updatedBy) 제외, 스키마 이름은 웹·앱 생성 타입 호환용 "ConceptTag" 유지
 */
@Schema(name = "ConceptTag")
public record ConceptTagResponse(
        UUID conceptTagUuid,
        String tagKey,
        String labelKo,
        String category,
        String description,
        Boolean isActive,
        Integer sortOrder
) {

    /** 개념 태그 엔티티 > 공개 응답 */
    public static ConceptTagResponse from(ConceptTag conceptTag) {
        return new ConceptTagResponse(
                conceptTag.getConceptTagUuid(),
                conceptTag.getTagKey(),
                conceptTag.getLabelKo(),
                conceptTag.getCategory(),
                conceptTag.getDescription(),
                conceptTag.getIsActive(),
                conceptTag.getSortOrder()
        );
    }
}
