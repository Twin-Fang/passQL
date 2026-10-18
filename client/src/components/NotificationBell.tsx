import { useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { Bell } from "lucide-react";
import { useNotificationSelection } from "../hooks/useNotificationSelection";
import { useMarkAllNotificationsRead, useRecentNotifications } from "../hooks/useNotifications";
import { useUnreadNotificationCount } from "../hooks/useUnreadNotificationCount";
import { toUnreadBadgeLabel } from "../lib/notificationPresentation";
import NotificationListState from "./NotificationListState";
import NotificationRow from "./NotificationRow";

/** 헤더 종 아이콘: 안 읽은 개수 배지 + 최근 5건 드롭다운 (#491) */
export default function NotificationBell() {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const { unreadCount } = useUnreadNotificationCount();
  const recent = useRecentNotifications(isDropdownOpen);
  const { mutate: markAllRead } = useMarkAllNotificationsRead();
  const { selectNotification } = useNotificationSelection(() =>
    setIsDropdownOpen(false),
  );

  // 바깥 클릭·ESC 로 닫기
  useEffect(() => {
    if (!isDropdownOpen) return;
    const onPointerDown = (event: PointerEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) setIsDropdownOpen(false);
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") setIsDropdownOpen(false);
    };
    document.addEventListener("pointerdown", onPointerDown);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("pointerdown", onPointerDown);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [isDropdownOpen]);

  const badgeLabel = toUnreadBadgeLabel(unreadCount.total);
  const bellAriaLabel = unreadCount.total > 0 ? `알림 ${unreadCount.total}개 안 읽음` : "알림";

  /** 모두 읽음: 알림·공지 두 탭 */
  const onMarkAllReadPressed = () => {
    if (unreadCount.general > 0) markAllRead("GENERAL");
    if (unreadCount.notice > 0) markAllRead("NOTICE");
  };

  return (
    <div ref={containerRef} className="relative">
      <button
        type="button"
        onClick={() => setIsDropdownOpen((isOpen) => !isOpen)}
        aria-label={bellAriaLabel}
        aria-haspopup="true"
        aria-expanded={isDropdownOpen}
        className="relative flex items-center justify-center w-9 h-9 rounded-full text-text-secondary hover:bg-surface transition-colors cursor-pointer"
      >
        <Bell size={20} />
        {badgeLabel && (
          <span className="absolute -top-0.5 -right-0.5 min-w-4.5 h-4.5 px-1 rounded-full bg-semantic-warning text-warning-content text-micro font-bold leading-[18px] text-center">
            {badgeLabel}
          </span>
        )}
      </button>

      {isDropdownOpen && (
        <div className="absolute right-0 top-full mt-2 z-50 w-[min(22rem,calc(100vw-2rem))] bg-surface-card border border-border rounded-2xl shadow-lg overflow-hidden">
          <div className="flex items-center justify-between px-4 py-3 border-b border-border">
            <h2 className="text-sm font-semibold text-text-primary">알림</h2>
            <button
              type="button"
              onClick={onMarkAllReadPressed}
              disabled={unreadCount.total === 0}
              className="text-xs font-semibold text-brand disabled:text-text-caption cursor-pointer disabled:cursor-default"
            >
              모두 읽음
            </button>
          </div>
          <div className="max-h-96 overflow-y-auto">
            <NotificationListState
              isLoading={recent.isLoading}
              isError={recent.isError}
              isEmpty={recent.recentNotifications.length === 0}
              emptyMessage="새로운 알림이 없어요"
              onRetry={() => void recent.refetch()}
            >
              <ul className="divide-y divide-border">
                {recent.recentNotifications.map((notification) => (
                  <NotificationRow
                    key={`${notification.category}-${notification.id}`}
                    notification={notification}
                    onSelected={selectNotification}
                  />
                ))}
              </ul>
            </NotificationListState>
          </div>
          <Link
            to="/notifications"
            onClick={() => setIsDropdownOpen(false)}
            className="block px-4 py-3 text-center text-sm font-semibold text-brand border-t border-border hover:bg-surface"
          >
            알림함 전체 보기
          </Link>
        </div>
      )}
    </div>
  );
}
