import type { QueryClient } from "@tanstack/react-query";

// 히트맵 쿼리 키 첫 요소 (useHeatmap 조회 키 접두사)
export const HEATMAP_QUERY_KEY_PREFIX = "heatmap";
// 학습 현황 쿼리 키 첫 요소 (useProgress 조회 키 접두사)
export const PROGRESS_QUERY_KEY_PREFIX = "progress";

/**
 * 풀이 기록 반영 쿼리 무효화: 히트맵, 학습 현황 (접두사 일치 전체)
 */
export function invalidateLearningRecordQueries(queryClient: QueryClient): void {
  queryClient.invalidateQueries({ queryKey: [HEATMAP_QUERY_KEY_PREFIX] });
  queryClient.invalidateQueries({ queryKey: [PROGRESS_QUERY_KEY_PREFIX] });
}
