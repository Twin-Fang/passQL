package com.passql.submission.dto.examanswer;

/**
 * 관리자 문항 1개 수정 (일괄 입력 배열 원소, 검증은 ExamAnswerAdminService): null 필드는 그대로 유지
 * 지우기: 문자열 "", operatorAnswer 0 / operatorAnswerStatus: UNKNOWN·LEADING·DISPUTED·CONFIRMED·OFFICIAL
 */
public record AdminExamAnswerItemUpdateRequest(
    Integer questionNo,
    String conceptTitle,
    String conceptTags,
    String topicCode,
    Integer operatorAnswer,
    String operatorAnswerStatus,
    String alternativeAnswers,
    String note) {
}
