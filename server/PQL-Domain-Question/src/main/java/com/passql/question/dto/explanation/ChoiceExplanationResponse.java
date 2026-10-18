package com.passql.question.dto.explanation;

import com.passql.question.constant.ChoiceExplanationStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 선택지 해설 조회 응답 (#521): 기다리지 않고 바로 상태를 돌려준다
 * - READY: explanation(구조화, 고정 세트·옛 해설이면 null) + text(마크다운, 항상 있음)
 * - GENERATING: retryAfterMilliseconds 뒤 같은 요청으로 다시 조회 (text 는 옛 해설이 있으면 임시 표시용)
 * - FAILED: 재시도 상한 도달, text 는 옛 해설이 있으면 표시용 (없으면 null)
 */
public record ChoiceExplanationResponse(
    @Schema(description = "해설 상태") ChoiceExplanationStatus status,
    @Schema(description = "해설 대상 선택지 세트") UUID choiceSetUuid,
    @Schema(description = "고른 보기 키") String selectedChoiceKey,
    @Schema(nullable = true, description = "구조화 해설 (READY 이고 AI 구조화 해설이 있을 때만)") ChoiceExplanation explanation,
    @Schema(nullable = true, description = "마크다운 해설 (구조화 해설을 그린 글 또는 고정 세트 근거·옛 해설)") String text,
    @Schema(nullable = true, description = "해설을 만든 프롬프트 버전") Integer promptVersion,
    @Schema(nullable = true, description = "GENERATING 일 때 다시 조회할 간격 (밀리초)") Integer retryAfterMilliseconds
) {}
