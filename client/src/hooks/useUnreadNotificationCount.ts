import { useQuery } from "@tanstack/react-query";
import { fetchUnreadNotificationCount } from "../api/notifications";
import { useAuthStore } from "../stores/authStore";
import { useMaintenanceStore } from "../stores/maintenanceStore";

// 안 읽은 개수 캐시 유지 시간 (30초, 중복 요청 병합 + 포커스 복귀 시 과호출 방지)
const UNREAD_COUNT_STALE_MILLISECONDS = 1000 * 30;

// 알림 관련 모든 쿼리의 공통 접두사 (읽음 처리 후 한 번에 무효화)
export const NOTIFICATIONS_QUERY_KEY = ["notifications"] as const;

const EMPTY_UNREAD_COUNT = { general: 0, notice: 0, total: 0 } as const;

/**
 * 안 읽은 알림 개수: 웹에서 unread-count 를 부르는 유일한 지점 (#491)
 * 갱신 시점 = 로그인 직후, 마운트(페이지 진입), 창 포커스 복귀, 읽음 처리 후 (폴링 없음)
 * 로그아웃·점검(503) 중에는 조회 중단
 */
export function useUnreadNotificationCount() {
  const memberUuid = useAuthStore((state) => state.memberUuid);
  const hasAccessToken = useAuthStore((state) => state.accessToken !== null);
  const isMaintenanceDetectedByApi = useMaintenanceStore((state) => state.isMaintenanceDetectedByApi);

  const query = useQuery({
    queryKey: [...NOTIFICATIONS_QUERY_KEY, "unread-count", memberUuid],
    queryFn: fetchUnreadNotificationCount,
    enabled: hasAccessToken && !isMaintenanceDetectedByApi,
    staleTime: UNREAD_COUNT_STALE_MILLISECONDS,
    refetchOnWindowFocus: true,
    retry: false,
  });

  return { ...query, unreadCount: query.data ?? EMPTY_UNREAD_COUNT };
}
