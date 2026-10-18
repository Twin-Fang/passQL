import { useNavigate } from "react-router-dom";
import { toNoticeDetailPath } from "../lib/noticePresentation";
import { resolveNotificationRoute } from "../lib/notificationPresentation";
import { useMarkNotificationRead } from "./useNotifications";
import type { NotificationItem } from "../types/api";

/**
 * 알림 항목 선택 공통 동작: 읽음 처리 > 공지는 공지 상세(#529), 알림은 연결 화면 이동 (드롭다운·알림함 공용)
 * 읽음 요청이 실패해도 이동은 진행
 */
export function useNotificationSelection(onSelected?: () => void) {
  const navigate = useNavigate();
  const { mutate: markNotificationRead } = useMarkNotificationRead();

  const selectNotification = (notification: NotificationItem) => {
    if (!notification.isRead) markNotificationRead({ notification });
    onSelected?.();
    const route =
      notification.category === "NOTICE" ? toNoticeDetailPath(notification.id) : resolveNotificationRoute(notification);
    if (route) navigate(route);
  };

  return { selectNotification };
}
