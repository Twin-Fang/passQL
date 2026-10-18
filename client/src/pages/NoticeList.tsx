import { Link } from "react-router-dom";
import { ChevronRight } from "lucide-react";
import ImportantBadge from "../components/ImportantBadge";
import NotificationListState from "../components/NotificationListState";
import SubpageLayout from "../components/SubpageLayout";
import { useNoticeList } from "../hooks/useNotices";
import { formatNoticeDate, toNoticeDetailPath, toNoticePreview } from "../lib/noticePresentation";

/** 공지 목록: 지난 공지 포함, 노출 중 중요 먼저 > 게시 최신 순, 페이지 더 보기 (#529) */
export default function NoticeList() {
  const noticeList = useNoticeList();
  const notices = noticeList.data?.pages.flatMap((page) => page.notices) ?? [];

  return (
    <SubpageLayout title="공지사항">
      <div className="max-w-2xl mx-auto bg-surface-card border border-border rounded-2xl overflow-hidden">
        <NotificationListState
          isLoading={noticeList.isLoading}
          isError={noticeList.isError}
          isEmpty={notices.length === 0}
          emptyMessage="등록된 공지가 없어요"
          onRetry={() => void noticeList.refetch()}
        >
          <ul className="divide-y divide-border">
            {notices.map((notice) => (
              <li key={notice.noticeUuid}>
                <Link
                  to={toNoticeDetailPath(notice.noticeUuid)}
                  className="flex items-center gap-3 px-4 py-4 hover:bg-surface transition-colors"
                >
                  <span className="flex-1 min-w-0">
                    <span className="flex items-center gap-1.5">
                      {notice.isImportant && <ImportantBadge />}
                      <span className="truncate text-sm font-semibold text-text-primary">{notice.title}</span>
                    </span>
                    <span className="block mt-1 text-xs text-text-secondary line-clamp-2 break-keep">
                      {toNoticePreview(notice.body)}
                    </span>
                    <span className="block mt-1.5 text-xs text-text-caption tabular-nums">
                      {formatNoticeDate(notice.publishedAt)}
                    </span>
                  </span>
                  <ChevronRight size={16} className="shrink-0 text-text-caption" />
                </Link>
              </li>
            ))}
          </ul>
          {noticeList.hasNextPage && (
            <button
              type="button"
              onClick={() => void noticeList.fetchNextPage()}
              disabled={noticeList.isFetchingNextPage}
              className="w-full py-3 text-sm font-semibold text-brand border-t border-border hover:bg-surface cursor-pointer"
            >
              {noticeList.isFetchingNextPage ? "불러오는 중..." : "더 보기"}
            </button>
          )}
        </NotificationListState>
      </div>
    </SubpageLayout>
  );
}
