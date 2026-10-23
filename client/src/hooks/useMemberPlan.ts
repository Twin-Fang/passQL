import { useQuery } from "@tanstack/react-query";
import { fetchMyPlan } from "../api/members";
import { shouldShowProBadgeForPlan, shouldShowProUiForPlan } from "../lib/proAccess";
import { useMemberQueryScope } from "./useMemberQueryScope";

// 등급 캐시 유지 시간 (5분, 구매는 앱에서 > 웹은 화면 재진입 시 반영이면 충분)
const MEMBER_PLAN_STALE_MILLISECONDS = 1000 * 60 * 5;

/**
 * 내 등급 단일 원본: GET /members/me/plan (#578)
 * 실패·로딩 = 등급 모름 > 잠금 UI·칩 모두 그리지 않음 (재시도 없음)
 */
export function useMemberPlan() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  const query = useQuery({
    queryKey: ["memberPlan", memberUuid],
    queryFn: fetchMyPlan,
    enabled: isMemberQueryEnabled,
    staleTime: MEMBER_PLAN_STALE_MILLISECONDS,
    retry: false,
  });
  return {
    plan: query.data,
    shouldShowProUi: shouldShowProUiForPlan(query.data),
    shouldShowProBadge: shouldShowProBadgeForPlan(query.data),
  };
}
