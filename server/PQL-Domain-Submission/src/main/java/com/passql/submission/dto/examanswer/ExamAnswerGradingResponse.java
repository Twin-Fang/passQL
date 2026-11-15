package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 가채점 결과: 과목별 점수·과락, 총점·범위, 합격 판정, 상위 %, 문항별 정오
 */
public record ExamAnswerGradingResponse(
    @Schema(description = "1과목 (만점 20)") ExamAnswerSubjectScoreResponse subject1,
    @Schema(description = "2과목 (만점 80)") ExamAnswerSubjectScoreResponse subject2,
    @Schema(description = "총점 (표시용 정답 기준)") int totalScore,
    @Schema(description = "총점 범위 (확정 안 된 문항 틀림/맞음 가정)") ExamAnswerScoreRangeResponse scoreRange,
    @Schema(description = "합격 판정: PASS, FAIL, BORDERLINE(범위가 합격선·과락선에 걸침)") String passStatus,
    @Schema(description = "참여자 중 상위 % (1~100, 올림, 참여 10명 미만이면 null)") Integer percentile,
    @Schema(description = "문항별 결과 50개") List<ExamAnswerQuestionResultResponse> perQuestion) {
}
