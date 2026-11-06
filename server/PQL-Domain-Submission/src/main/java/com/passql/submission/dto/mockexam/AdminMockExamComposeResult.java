package com.passql.submission.dto.mockexam;

import java.util.List;
import java.util.UUID;

/**
 * 자동 구성 결과: 만든 초안 회차, 경고(모자란 토픽·최근 회차 겹침)
 */
public record AdminMockExamComposeResult(UUID roundUuid, int itemCount, List<String> warnings) {
}
