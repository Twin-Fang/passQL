import { useQuery } from "@tanstack/react-query";
import { fetchAiComment } from "../api/progress";

/**
 * 연습 세트 AI 코멘트: sessionId 단위 캐시 — 세션마다 새 피드백
 * 반환 3상태: 로딩 null(스켈레톤), 실패 false(영역 숨김), 성공 텍스트
 */
export function usePracticeAiComment(sessionId: string | undefined): string | null | false {
  const {
    data: aiCommentData,
    isLoading: aiCommentLoading,
    isError: aiCommentError,
  } = useQuery({
    queryKey: ["aiComment", sessionId],
    queryFn: () => fetchAiComment(sessionId!),
    staleTime: 1000 * 60 * 60 * 2, // 2시간 — 백엔드 Redis TTL과 맞춤
    enabled: !!sessionId,
    retry: 1,
  });
  return aiCommentLoading
    ? null
    : aiCommentError
      ? false
      : (aiCommentData?.comment ?? "");
}
