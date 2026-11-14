package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 회차 가답안 전체 (공개): 회차 정보·채점 규칙·50문항·참여자 수 (득표 집계는 최대 60초 지연)
 */
public record ExamAnswerRoundResponse(
    @Schema(description = "자격증 (SQLD)") String certType,
    @Schema(description = "회차 번호") int roundNumber,
    @Schema(description = "제목") String title,
    @Schema(description = "시험일") LocalDate examDate,
    @Schema(description = "회차 상태: COLLECTING 수집 중, OFFICIAL 공식 정답 반영, CLOSED 마감(제출 불가)") String status,
    @Schema(description = "안내 문구 (없으면 null)") String notice,
    @Schema(description = "채점 규칙") ExamAnswerGradingRuleResponse gradingRule,
    @Schema(description = "답안 제출 참여자 수") int participantCount,
    @Schema(description = "집계 기준 시각 (KST)") LocalDateTime updatedAt,
    @Schema(description = "문항 50개 (번호 오름차순)") List<ExamAnswerItemResponse> items) {
}
