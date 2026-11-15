package com.passql.submission.dto;

import java.util.List;
import java.util.UUID;

/** 즐겨찾기 풀기 묶음 (#1082): 활성 즐겨찾기 문제 무작위 최대 10개 */
public record QuestionBookmarkPracticeSetResponse(
    List<UUID> questionUuids
) {}
