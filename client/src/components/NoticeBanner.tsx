import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Megaphone, X } from "lucide-react";
import { useMarkNotificationRead, useNotificationInbox } from "../hooks/useNotifications";
import { useUnreadNotificationCount } from "../hooks/useUnreadNotificationCount";
import { toNoticeDetailPath } from "../lib/noticePresentation";
import ImportantBadge from "./ImportantBadge";

/**
 * 공지 배너: 안 읽은 중요 공지 첫 건 (#464, #491)
 * 클릭 > 읽음 + 공지 상세 이동 (#529), 닫기 > 서버 읽음 (요청 실패해도 이번 화면에서는 닫힘)
 * 안 읽은 공지가 없으면 목록을 조회하지 않음 (IO 절약)
 */
export default function NoticeBanner() {
  const { unreadCount } = useUnreadNotificationCount();
  const { data: noticeInbox } = useNotificationInbox("NOTICE", unreadCount.notice > 0);
  const { mutate: markNotificationRead } = useMarkNotificationRead();
  // 읽음 요청 결과와 무관하게 즉시 숨길 공지 (낙관적)
  const [closedNoticeIds, setClosedNoticeIds] = useState<ReadonlySet<string>>(new Set());
  const navigate = useNavigate();

  const notice = noticeInbox?.pages
    .flatMap((page) => page.items)
    .find((candidate) => candidate.isImportant && !candidate.isRead && !closedNoticeIds.has(candidate.id));
  if (!notice) return null;

  /** 배너에서 숨기고 서버에 읽음 기록 */
  const closeNoticeAsRead = () => {
    setClosedNoticeIds((closedIds) => new Set(closedIds).add(notice.id));
    markNotificationRead({ notification: notice });
  };

  return (
    <section
      aria-label="공지"
      className="flex items-center gap-2 bg-surface-card border border-border rounded-2xl pl-4 pr-1 py-1 mt-4 lg:mt-0 mb-4"
    >
      <button
        type="button"
        onClick={() => {
          closeNoticeAsRead();
          navigate(toNoticeDetailPath(notice.id));
        }}
        className="flex-1 min-w-0 flex items-center gap-2 py-2 text-left cursor-pointer"
      >
        <Megaphone size={18} className="shrink-0 text-brand" />
        <ImportantBadge />
        <span className="truncate text-sm font-semibold text-text-primary">{notice.title}</span>
      </button>
      <button
        type="button"
        onClick={closeNoticeAsRead}
        aria-label="공지 닫기"
        className="shrink-0 flex items-center justify-center w-10 h-10 text-text-caption hover:text-text-secondary cursor-pointer"
      >
        <X size={16} />
      </button>
    </section>
  );
}
