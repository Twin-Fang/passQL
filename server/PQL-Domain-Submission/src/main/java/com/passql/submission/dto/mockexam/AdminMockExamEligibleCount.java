package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamSubject;

/**
 * 관리자 전용 토픽별 출제 가능 문제 수 (사용자 노출 금지 #636), 기본 구성 문항 수와 비교
 */
public record AdminMockExamEligibleCount(String topicCode, String topicName, MockExamSubject subject,
                                         long eligibleQuestionCount, int defaultTargetCount) {
}
