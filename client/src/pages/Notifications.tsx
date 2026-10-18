import { useState } from "react";
import { Link } from "react-router-dom";
import { ChevronRight } from "lucide-react";
import { useNotificationSelection } from "../hooks/useNotificationSelection";
import { useMarkAllNotificationsRead, useNotificationInbox } from "../hooks/useNotifications";
import { useUnreadNotificationCount } from "../hooks/useUnreadNotificationCount";
import NotificationListState from "../components/NotificationListState";
import NotificationRow from "../components/NotificationRow";
import { NOTICE_LIST_PATH } from "../lib/noticePresentation";
import type { NotificationCategory } from "../types/api";

const INBOX_TABS: readonly { readonly category: NotificationCategory; readonly label: string; readonly emptyMessage: string }[] = [
  { category: "GENERAL", label: "알림", emptyMessage: "받은 알림이 없어요" },
  { category: "NOTICE", label: "공지", emptyMessage: "등록된 공지가 없어요" },
];

/** 알림함 페이지: 알림 | 공지 탭, 탭별 안 읽은 개수, 모두 읽음, 커서 더 보기 (#491), 공지 탭 > 지난 공지 전체 (#529) */
export default function Notifications() {
  const [selectedCategory, setSelectedCategory] = useState<NotificationCategory>("GENERAL");
  const { unreadCount } = useUnreadNotificationCount();
  const inbox = useNotificationInbox(selectedCategory);
  const { mutate: markAllRead, isPending: isMarkingAllRead } = useMarkAllNotificationsRead();
  const { selectNotification } = useNotificationSelection();

  const selectedTab = INBOX_TABS.find((tab) => tab.category === selectedCategory) ?? INBOX_TABS[0];
  const notifications = inbox.data?.pages.flatMap((page) => page.items) ?? [];
  const unreadCountByCategory: Record<NotificationCategory, number> = {
    GENERAL: unreadCount.general,
    NOTICE: unreadCount.notice,
  };

  return (
    <div className="pt-4 lg:pt-0">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-h2 text-text-primary">알림함</h1>
        <button
          type="button"
          onClick={() => markAllRead(selectedCategory)}
          disabled={unreadCountByCategory[selectedCategory] === 0 || isMarkingAllRead}
          className="text-sm font-semibold text-brand disabled:text-text-caption cursor-pointer disabled:cursor-default"
        >
          모두 읽음
        </button>
      </div>

      <div role="tablist" className="tabs tabs-box mb-4">
        {INBOX_TABS.map((tab) => (
          <button
            key={tab.category}
            type="button"
            role="tab"
            aria-selected={tab.category === selectedCategory}
            onClick={() => setSelectedCategory(tab.category)}
            className={`tab flex-1 gap-1.5 ${tab.category === selectedCategory ? "tab-active" : ""}`}
          >
            {tab.label}
            {unreadCountByCategory[tab.category] > 0 && (
              <span className="px-1.5 rounded-full bg-semantic-warning text-warning-content text-xs font-bold">
                {unreadCountByCategory[tab.category]}
              </span>
            )}
          </button>
        ))}
      </div>

      <div className="bg-surface-card border border-border rounded-2xl overflow-hidden">
        <NotificationListState
          isLoading={inbox.isLoading}
          isError={inbox.isError}
          isEmpty={notifications.length === 0}
          emptyMessage={selectedTab.emptyMessage}
          onRetry={() => void inbox.refetch()}
        >
          <ul className="divide-y divide-border">
            {notifications.map((notification) => (
              <NotificationRow
                key={`${notification.category}-${notification.id}`}
                notification={notification}
                onSelected={selectNotification}
              />
            ))}
          </ul>
          {inbox.hasNextPage && (
            <button
              type="button"
              onClick={() => void inbox.fetchNextPage()}
              disabled={inbox.isFetchingNextPage}
              className="w-full py-3 text-sm font-semibold text-brand border-t border-border hover:bg-surface cursor-pointer"
            >
              {inbox.isFetchingNextPage ? "불러오는 중..." : "더 보기"}
            </button>
          )}
        </NotificationListState>
      </div>

      {/* 공지 탭은 노출 중 공지만 > 지난 공지까지 보는 목록 링크 */}
      {selectedCategory === "NOTICE" && (
        <Link
          to={NOTICE_LIST_PATH}
          className="mt-3 flex items-center justify-center gap-1 py-3 text-sm font-semibold text-brand hover:underline"
        >
          지난 공지 전체 보기
          <ChevronRight size={16} />
        </Link>
      )}
    </div>
  );
}
