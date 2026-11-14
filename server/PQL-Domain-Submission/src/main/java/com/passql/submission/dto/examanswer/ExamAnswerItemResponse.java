package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.Map;

/**
 * 가답안 문항 1개 (원문 없음): 번호·과목·출제 개념·표시용 정답·득표 분포·합의율
 */
public record ExamAnswerItemResponse(
    @Schema(description = "문항 번호 (1~50)") int questionNo,
    @Schema(description = "과목 번호 (1: 1~10번, 2: 11~50번)") int subjectNo,
    @Schema(description = "출제 개념 한 줄 (없으면 null)") String conceptTitle,
    @Schema(description = "개념 태그") List<String> conceptTags,
    @Schema(description = "연결 토픽 코드 (없으면 null)") String topicCode,
    @Schema(description = "표시용 정답 1~4: 상태 OFFICIAL·CONFIRMED·LEADING 이면 운영 가답안, 아니면 득표 1위 (득표 없으면 null)") Integer answer,
    @Schema(description = "운영 가답안 상태: UNKNOWN 모름, LEADING 우세, DISPUTED 갈림, CONFIRMED 확정, OFFICIAL 공식") String answerStatus,
    @Schema(description = "복수 정답 인정 보기 (없으면 빈 목록)") List<Integer> alternativeAnswers,
    @Schema(description = "보기별 득표 수 (키 \"1\"~\"4\")") Map<String, Integer> tally,
    @Schema(description = "이 문항에 보기를 고른 답안 수 (모름 제외)") int voteCount,
    @Schema(description = "합의율 0~1: 표시용 정답 득표 / voteCount (득표 없으면 0)") double agreementRate,
    @Schema(description = "메모 한 줄 (갈림 이유 등, 없으면 null)") String note) {
}
