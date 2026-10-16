import { apiFetch } from "./client";
import type { NotificationCategory, NotificationPage, UnreadNotificationCount } from "../types/api";

export const NOTIFICATION_PAGE_SIZE = 20;

/** 알림 목록 (커서 기반, 탭별) */
export function fetchNotifications(
  category: NotificationCategory,
  cursor: string | null,
  size: number = NOTIFICATION_PAGE_SIZE,
): Promise<NotificationPage> {
  const params = new URLSearchParams({ category, size: String(size) });
  if (cursor) params.set("cursor", cursor);
  return apiFetch(`/members/me/notifications?${params}`);
}

/** 안 읽은 개수: useUnreadNotificationCount 에서만 호출 (규칙 테스트로 강제) */
export function fetchUnreadNotificationCount(): Promise<UnreadNotificationCount> {
  return apiFetch("/members/me/notifications/unread-count");
}

export function markNotificationRead(notificationId: string, category: NotificationCategory): Promise<void> {
  const params = new URLSearchParams({ category });
  return apiFetch(`/members/me/notifications/${encodeURIComponent(notificationId)}/read?${params}`, { method: "POST" });
}

export function markAllNotificationsRead(category: NotificationCategory): Promise<void> {
  const params = new URLSearchParams({ category });
  return apiFetch(`/members/me/notifications/read-all?${params}`, { method: "POST" });
}
