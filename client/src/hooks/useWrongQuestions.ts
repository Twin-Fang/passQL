import { useQuery } from "@tanstack/react-query";
import { fetchWrongQuestions } from "../api/progress";
import { useMemberQueryScope } from "./useMemberQueryScope";

// 오답 목록 캐시 유지 시간 (5분)
const WRONG_QUESTIONS_STALE_MILLISECONDS = 1000 * 60 * 5;

/**
 * 최근 오답 목록 조회 (마이페이지 미리보기·오답 노트 화면 공용)
 * 프로 전용 > 무료(결제 켜짐)는 403 PRO_REQUIRED, 호출부가 잠금 미리보기로 분기
 */
export function useWrongQuestions(size: number) {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: ["wrongQuestions", memberUuid, size],
    queryFn: () => fetchWrongQuestions(size),
    enabled: isMemberQueryEnabled,
    staleTime: WRONG_QUESTIONS_STALE_MILLISECONDS,
  });
}
