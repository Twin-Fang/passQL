package com.passql.meta.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;
import java.util.UUID;

public record TopicTree(UUID topicUuid, String code, String displayName, @Schema(nullable = true) Integer sortOrder, Boolean isActive, List<SubtopicItem> subtopics) {
    public record SubtopicItem(String code, String displayName, @Schema(nullable = true) Integer sortOrder, Boolean isActive) {}
}
