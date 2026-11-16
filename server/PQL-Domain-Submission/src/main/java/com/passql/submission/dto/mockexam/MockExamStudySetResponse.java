package com.passql.submission.dto.mockexam;

import java.util.List;
import java.util.UUID;

/**
 * 학습 모드 문항 (#1084): 회차, 제목, 시험 번호 순서 문제 uuid 50개
 */
public record MockExamStudySetResponse(UUID roundUuid, String title, List<UUID> questionUuids) {
}
