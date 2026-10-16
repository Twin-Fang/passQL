import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { resolveNotificationRoute } from "../lib/notificationPresentation";
import { useMarkNotificationRead } from "./useNotifications";
import type { NotificationItem } from "../types/api";

/**
 * 알림 항목 선택 공통 동작: 읽음 처리 > 공지는 본문 모달, 알림은 연결 화면 이동 (드롭다운·알림함 공용)
 * 읽음 요청이 실패해도 이동·모달은 진행
 */
export function useNotificationSelection(onSelected?: () => void) {
  const navigate = useNavigate();
  const { mutate: markNotificationRead } = useMarkNotificationRead();
  const [openedNotice, setOpenedNotice] = useState<NotificationItem | null>(null);

  const selectNotification = (notification: NotificationItem) => {
    if (!notification.isRead) markNotificationRead({ notification });
    onSelected?.();
    if (notification.category === "NOTICE") {
      setOpenedNotice(notification);
      return;
    }
    const route = resolveNotificationRoute(notification);
    if (route) navigate(route);
  };

  return { selectNotification, openedNotice, closeOpenedNotice: () => setOpenedNotice(null) };
}
