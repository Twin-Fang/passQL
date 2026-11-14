package com.passql.submission.dto.examanswer;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * OMR 답안 제출 (기기·브라우저당 1장, 같은 clientToken 재제출은 갱신)
 */
public record ExamAnswerSheetSubmitRequest(
    @Schema(description = "클라이언트가 만든 식별 토큰 (UUID 권장, 8~100자 영문·숫자·-_), 서버는 SHA-256 해시만 저장")
    @NotBlank @Pattern(regexp = "^[A-Za-z0-9_-]{8,100}$") String clientToken,
    @Schema(description = "50자, 자리마다 0 모름 · 1~4 고른 보기 (1번 문항부터)", example = "13420000000000000000000000000000000000000000000000")
    @NotBlank @Pattern(regexp = "^[0-4]{50}$") String answers,
    @Schema(description = "제출 경로 WEB | APP (없으면 WEB)") String source) {
}
