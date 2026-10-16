import { useQuery } from "@tanstack/react-query";
import { fetchProgress } from "../api/progress";
import { useMemberQueryScope } from "./useMemberQueryScope";

export function useProgress() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  // staleTime 전역 기본값 사용: 제출 훅이 제출 직후 progress 무효화 (#497)
  return useQuery({
    queryKey: ["progress", memberUuid],
    queryFn: fetchProgress,
    enabled: isMemberQueryEnabled,
    retry: false,
  });
}
