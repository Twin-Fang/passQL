import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchMyFeedback, submitFeedback } from "../api/feedback";
import { useMemberQueryScope } from "./useMemberQueryScope";

// 내 건의사항 캐시 키 접두사 (회원별 키는 뒤에 memberUuid)
const MY_FEEDBACK_QUERY_KEY = ["feedback", "my"] as const;

/**
 * 내 건의사항 목록 쿼리
 * - 빈 목록: 200 + { items: [] } (API 스펙 보장 — 404 없음)
 * - 에러 → throw (ErrorFallback 렌더링)
 */
export function useMyFeedback() {
  // 회원별 키 + 로그아웃 시 호출 안 함 (계정 전환 시 이전 회원 건의사항 노출 방지)
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: [...MY_FEEDBACK_QUERY_KEY, memberUuid],
    queryFn: fetchMyFeedback,
    enabled: isMemberQueryEnabled,
    staleTime: 0, // 페이지 진입 시마다 최신 상태 반영 (PENDING→REVIEWED→APPLIED 변화 감지)
    retry: false,
  });
}

/**
 * 건의사항 제출 mutation
 * - 성공 시 목록 캐시 무효화 → 자동 refetch
 */
export function useSubmitFeedback() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: submitFeedback,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: MY_FEEDBACK_QUERY_KEY });
    },
  });
}
