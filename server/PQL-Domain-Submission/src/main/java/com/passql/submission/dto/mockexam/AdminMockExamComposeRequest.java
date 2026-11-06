package com.passql.submission.dto.mockexam;

import java.util.Map;

/**
 * 자동 구성 요청: 회차 번호·제목, 토픽 코드별 문항 수 (null·빈 값이면 기본 비율 MockExamComposition)
 */
public record AdminMockExamComposeRequest(Integer roundNumber, String title, Map<String, Integer> questionCountByTopicCode) {
}
