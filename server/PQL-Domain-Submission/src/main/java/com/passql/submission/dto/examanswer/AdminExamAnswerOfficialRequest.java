package com.passql.submission.dto.examanswer;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * 공식 정답 일괄 입력: 50자 (자리마다 1~4, 0 은 그 문항 건너뜀) > 해당 문항 OFFICIAL, 회차 OFFICIAL
 */
public record AdminExamAnswerOfficialRequest(
    @NotBlank @Pattern(regexp = "^[0-4]{50}$") String answers) {
}
