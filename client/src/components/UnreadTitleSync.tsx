import { useEffect } from "react";
import { useUnreadNotificationCount } from "../hooks/useUnreadNotificationCount";
import { toDocumentTitle } from "../lib/notificationPresentation";

/** 브라우저 탭 제목에 안 읽은 개수 반영: "(3) passQL" (화면 없음) */
export default function UnreadTitleSync() {
  const { unreadCount } = useUnreadNotificationCount();
  useEffect(() => {
    document.title = toDocumentTitle(unreadCount.total);
  }, [unreadCount.total]);
  return null;
}
