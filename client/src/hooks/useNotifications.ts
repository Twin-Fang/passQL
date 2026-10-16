import { useInfiniteQuery, useMutation, useQueries, useQueryClient } from "@tanstack/react-query";
import {
  fetchNotifications,
  markAllNotificationsRead,
  markNotificationRead,
} from "../api/notifications";
import { compareByNewest } from "../lib/notificationPresentation";
import { useAuthStore } from "../stores/authStore";
import { NOTIFICATIONS_QUERY_KEY } from "./useUnreadNotificationCount";
import type { NotificationCategory, NotificationItem } from "../types/api";

// 목록 캐시 유지 시간 (30초)
const NOTIFICATION_LIST_STALE_MILLISECONDS = 1000 * 30;
// 드롭다운 최근 알림 개수
export const DROPDOWN_NOTIFICATION_COUNT = 5;

const NOTIFICATION_CATEGORIES: readonly NotificationCategory[] = ["GENERAL", "NOTICE"];

/** 탭별 알림 목록 (커서 기반 더 보기) */
export function useNotificationInbox(category: NotificationCategory, isEnabled: boolean = true) {
  const memberUuid = useAuthStore((state) => state.memberUuid);
  return useInfiniteQuery({
    queryKey: [...NOTIFICATIONS_QUERY_KEY, "inbox", memberUuid, category],
    queryFn: ({ pageParam }) => fetchNotifications(category, pageParam),
    initialPageParam: null as string | null,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    enabled: isEnabled,
    staleTime: NOTIFICATION_LIST_STALE_MILLISECONDS,
    retry: false,
  });
}

/** 드롭다운용 최근 알림: 알림·공지 각 최근 5건을 합쳐 최신순 5건 (isEnabled 일 때만 조회) */
export function useRecentNotifications(isEnabled: boolean) {
  const memberUuid = useAuthStore((state) => state.memberUuid);
  const queries = useQueries({
    queries: NOTIFICATION_CATEGORIES.map((category) => ({
      queryKey: [...NOTIFICATIONS_QUERY_KEY, "recent", memberUuid, category],
      queryFn: () => fetchNotifications(category, null, DROPDOWN_NOTIFICATION_COUNT),
      enabled: isEnabled,
      staleTime: NOTIFICATION_LIST_STALE_MILLISECONDS,
      retry: false,
    })),
  });

  const recentNotifications: readonly NotificationItem[] = queries
    .flatMap((query) => query.data?.items ?? [])
    .sort(compareByNewest)
    .slice(0, DROPDOWN_NOTIFICATION_COUNT);

  return {
    recentNotifications,
    isLoading: queries.some((query) => query.isLoading),
    isError: queries.every((query) => query.isError),
    refetch: () => Promise.all(queries.map((query) => query.refetch())),
  };
}

/** 한 건 읽음 처리 > 알림 관련 쿼리 전체 갱신 (개수·목록) */
export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ notification }: { readonly notification: NotificationItem }) =>
      markNotificationRead(notification.id, notification.category),
    onSettled: () => queryClient.invalidateQueries({ queryKey: NOTIFICATIONS_QUERY_KEY }),
  });
}

/** 탭 전체 읽음 처리 > 알림 관련 쿼리 전체 갱신 */
export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (category: NotificationCategory) => markAllNotificationsRead(category),
    onSettled: () => queryClient.invalidateQueries({ queryKey: NOTIFICATIONS_QUERY_KEY }),
  });
}
