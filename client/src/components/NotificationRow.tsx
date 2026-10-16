import { Megaphone } from "lucide-react";
import { formatNotificationTime } from "../lib/notificationPresentation";
import type { NotificationItem } from "../types/api";

interface NotificationRowProps {
  readonly notification: NotificationItem;
  readonly onSelected: (notification: NotificationItem) => void;
}

/** 알림 한 줄: 안 읽음 주황 점 + 제목 + 본문 한 줄 + 상대 시간 */
export default function NotificationRow({ notification, onSelected }: NotificationRowProps) {
  return (
    <li>
      <button
        type="button"
        onClick={() => onSelected(notification)}
        className="w-full flex items-start gap-3 px-4 py-3 text-left hover:bg-surface transition-colors cursor-pointer"
      >
        {/* 안 읽음 표시 (읽으면 자리만 유지) */}
        <span
          aria-label={notification.isRead ? undefined : "안 읽음"}
          className={`mt-1.5 shrink-0 w-2 h-2 rounded-full ${notification.isRead ? "bg-transparent" : "bg-semantic-warning"}`}
        />
        <span className="flex-1 min-w-0">
          <span className="flex items-center gap-1.5">
            {notification.category === "NOTICE" && <Megaphone size={14} className="shrink-0 text-brand" />}
            {notification.isImportant && (
              <span className="shrink-0 px-1.5 py-0.5 rounded-md text-xs font-semibold text-semantic-error-text bg-semantic-error-light">
                중요
              </span>
            )}
            <span className={`truncate text-sm ${notification.isRead ? "text-text-secondary" : "font-semibold text-text-primary"}`}>
              {notification.title}
            </span>
          </span>
          <span className="block truncate text-xs text-text-caption mt-0.5">{notification.body}</span>
        </span>
        <span className="shrink-0 text-xs text-text-caption mt-0.5">
          {formatNotificationTime(notification.createdAt)}
        </span>
      </button>
    </li>
  );
}
