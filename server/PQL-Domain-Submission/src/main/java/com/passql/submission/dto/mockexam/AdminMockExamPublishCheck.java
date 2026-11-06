package com.passql.submission.dto.mockexam;

import java.util.List;

/**
 * 공개 검사: 오류(하나라도 있으면 공개 불가), 경고(공개 가능)
 */
public record AdminMockExamPublishCheck(boolean canPublish, List<String> errors, List<String> warnings) {
}
