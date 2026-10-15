import { useState } from "react";
import { Megaphone, X } from "lucide-react";
import { useAppConfig } from "../hooks/useAppConfig";
import { readDismissedNoticeUuids, saveDismissedNoticeUuid } from "../lib/dismissedNoticeStorage";
import NoticeModal from "./NoticeModal";

/**
 * 공지 배너: 닫지 않은 공지 중 서버 순서상 첫 건 (중요 먼저) (#464)
 * 클릭 > 본문 모달, 닫기 > 같은 noticeUuid 다시 안 띄움
 */
export default function NoticeBanner() {
  const { data: appConfig } = useAppConfig();
  const [dismissedNoticeUuids, setDismissedNoticeUuids] = useState(readDismissedNoticeUuids);
  const [isNoticeModalOpen, setIsNoticeModalOpen] = useState(false);

  const notice = appConfig?.notices.find(
    (candidate) => !dismissedNoticeUuids.has(candidate.noticeUuid),
  );
  if (!notice) return null;

  const onDismissPressed = () => {
    setIsNoticeModalOpen(false);
    setDismissedNoticeUuids(saveDismissedNoticeUuid(notice.noticeUuid));
  };

  return (
    <>
      <section
        aria-label="공지"
        className="flex items-center gap-2 bg-surface-card border border-border rounded-2xl pl-4 pr-1 py-1 mt-4 lg:mt-0 mb-4"
      >
        <button
          type="button"
          onClick={() => setIsNoticeModalOpen(true)}
          className="flex-1 min-w-0 flex items-center gap-2 py-2 text-left cursor-pointer"
        >
          <Megaphone size={18} className="shrink-0 text-brand" />
          {notice.isImportant && (
            <span className="shrink-0 px-1.5 py-0.5 rounded-md text-xs font-semibold text-semantic-error-text bg-semantic-error-light">
              중요
            </span>
          )}
          <span className="truncate text-sm font-semibold text-text-primary">{notice.title}</span>
        </button>
        <button
          type="button"
          onClick={onDismissPressed}
          aria-label="공지 닫기"
          className="shrink-0 flex items-center justify-center w-10 h-10 text-text-caption hover:text-text-secondary cursor-pointer"
        >
          <X size={16} />
        </button>
      </section>

      {isNoticeModalOpen && (
        <NoticeModal notice={notice} onClose={() => setIsNoticeModalOpen(false)} />
      )}
    </>
  );
}
