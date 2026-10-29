import { useCallback } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { fetchGreeting } from "../api/home";
import { fetchRecommendations } from "../api/questions";
import { fetchSelectedSchedule } from "../api/examSchedules";
import { fetchHeatmap } from "../api/progress";
import { fetchDailySet, fetchLeaderboard } from "../api/dailySet";
import { useMemberQueryScope } from "./useMemberQueryScope";
import { HEATMAP_QUERY_KEY_PREFIX } from "../lib/learningRecordQueries";
import type { DailySetTodayResponse, LeaderboardResponse } from "../types/api";

export function useGreeting() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: ["greeting", memberUuid],
    queryFn: fetchGreeting,
    enabled: isMemberQueryEnabled,
    staleTime: 1000 * 60 * 5,
    retry: false,
  });
}

const RECOMMENDATIONS_KEY = (memberUuid: string | null) =>
  ["recommendations", memberUuid] as const;

export function useRecommendations() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  // excludeUuids를 queryKey에 포함하면 seenUuids 변경마다 캐시 키가 달라져 무한 재요청 발생
  // → queryKey는 고정, excludeUuids는 useRefreshRecommendations에서 명시적 갱신 시에만 전달
  return useQuery({
    queryKey: RECOMMENDATIONS_KEY(memberUuid),
    queryFn: () => fetchRecommendations(3, []),
    // 미인증 상태에서 호출 방지 — null 키 캐시 엔트리 생성 방지
    enabled: isMemberQueryEnabled,
    staleTime: Infinity,
    retry: false,
  });
}

/**
 * 새로고침 버튼 클릭 시 seenUuids를 제외 목록으로 전달하여 캐시를 갱신하는 훅
 * useRecommendations의 queryKey는 고정이므로 setQueryData로 덮어쓴다
 */
export function useRefreshRecommendations() {
  const { memberUuid } = useMemberQueryScope();
  const queryClient = useQueryClient();
  // memberUuid·queryClient 변경 시에만 새 함수 참조 생성 — Home의 handleRefresh useCallback 안정화
  return useCallback(async (excludeUuids: string[]) => {
    const data = await fetchRecommendations(3, excludeUuids);
    queryClient.setQueryData(RECOMMENDATIONS_KEY(memberUuid), data);
  }, [memberUuid, queryClient]);
}

export function useSelectedSchedule() {
  return useQuery({
    queryKey: ["selectedSchedule"],
    queryFn: fetchSelectedSchedule,
    staleTime: 1000 * 60 * 30,
    retry: false,
  });
}

/** 로컬 타임존 기준 YYYY-MM-DD 반환 — toISOString()은 UTC 기준이라 KST에서 날짜 밀림 발생 */
function toLocalDateStr(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export function useHeatmap() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  const now = new Date();
  const today = toLocalDateStr(now);
  const fromDate = new Date(now);
  fromDate.setDate(fromDate.getDate() - 29);
  const from = toLocalDateStr(fromDate);
  return useQuery({
    queryKey: [HEATMAP_QUERY_KEY_PREFIX, memberUuid, from, today],
    queryFn: () => fetchHeatmap(from, today),
    enabled: isMemberQueryEnabled,
    staleTime: 1000 * 60 * 5,
    retry: false,
  });
}

export function useDailySet() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery<DailySetTodayResponse>({
    queryKey: ["dailySet", memberUuid],
    queryFn: fetchDailySet,
    enabled: isMemberQueryEnabled,
    staleTime: 1000 * 60 * 5,
    retry: false,
  });
}

export function useLeaderboard() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery<LeaderboardResponse>({
    queryKey: ["leaderboard", memberUuid],
    queryFn: fetchLeaderboard,
    enabled: isMemberQueryEnabled,
    staleTime: 1000 * 60,
    retry: false,
  });
}
