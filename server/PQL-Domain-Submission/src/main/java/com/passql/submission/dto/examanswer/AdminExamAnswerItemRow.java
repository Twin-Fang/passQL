package com.passql.submission.dto.examanswer;

import java.util.Map;

/**
 * 관리자 문항 편집 행: 운영 입력값 + 득표 현황 (표시용 정답·합의율)
 */
public record AdminExamAnswerItemRow(int questionNo, int subjectNo, String conceptTitle, String conceptTags,
                                     String topicCode, Integer operatorAnswer, String operatorAnswerStatus,
                                     String alternativeAnswers, String note, Integer displayedAnswer,
                                     Map<String, Integer> tally, int voteCount, double agreementRate) {
}
