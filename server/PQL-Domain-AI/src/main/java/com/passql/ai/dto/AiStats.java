package com.passql.ai.dto;

/**
 * 모니터링 화면용 AI 호출 통계 DTO.
 *
 * <p>geminiCallCount — GeminiClient 호출 횟수 (서버 기동 이후 누적, 인메모리 → 배포마다 0).
 * 실측값이 없는 항목(-1 미구현 표시)은 화면만 차지해 제거했다 (#440).
 */
public record AiStats(
        long geminiCallCount
) {
}
