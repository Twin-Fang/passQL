import { queryOptions, useQuery } from "@tanstack/react-query";
import { fetchAiComment } from "../api/progress";

// 2시간 — 백엔드 Redis TTL과 맞춤
const PRACTICE_AI_COMMENT_CACHE_MILLISECONDS = 1000 * 60 * 60 * 2;

/**
 * 연습 세트 AI 코멘트 쿼리 설정 (결과 화면 조회 <-> 마지막 제출 시 미리 받기 공용 키·함수)
 * gcTime = staleTime: 화면 이탈 후 재진입 시 LLM 재호출 방지
 */
export function practiceAiCommentQueryOptions(sessionId: string | undefined) {
  return queryOptions({
    queryKey: ["aiComment", sessionId],
    queryFn: () => fetchAiComment(sessionId!),
    staleTime: PRACTICE_AI_COMMENT_CACHE_MILLISECONDS,
    gcTime: PRACTICE_AI_COMMENT_CACHE_MILLISECONDS,
    enabled: !!sessionId,
    retry: 1,
  });
}

/**
 * 연습 세트 AI 코멘트: sessionId 단위 캐시 — 세션마다 새 피드백
 * 반환 3상태: 로딩 null(스켈레톤), 실패 false(영역 숨김), 성공 텍스트
 */
export function usePracticeAiComment(sessionId: string | undefined): string | null | false {
  const {
    data: aiCommentData,
    isLoading: aiCommentLoading,
    isError: aiCommentError,
  } = useQuery(practiceAiCommentQueryOptions(sessionId));
  return aiCommentLoading
    ? null
    : aiCommentError
      ? false
      : (aiCommentData?.comment ?? "");
}
