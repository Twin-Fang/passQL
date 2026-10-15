import { useQuery } from "@tanstack/react-query";
import { fetchAppConfig } from "../api/meta";

// 시작 설정 캐시 유지 시간 (5분, 점검 해제는 "다시 확인" 버튼으로 즉시 반영)
const APP_CONFIG_STALE_MILLISECONDS = 1000 * 60 * 5;

export const APP_CONFIG_QUERY_KEY = ["appConfig"] as const;

/**
 * 시작 설정 조회 (점검·공지) (#464)
 * 실패해도 사용을 막지 않음 > 재시도 없이 "설정 없음"으로 취급
 */
export function useAppConfig() {
  return useQuery({
    queryKey: APP_CONFIG_QUERY_KEY,
    queryFn: fetchAppConfig,
    staleTime: APP_CONFIG_STALE_MILLISECONDS,
    retry: false,
  });
}
