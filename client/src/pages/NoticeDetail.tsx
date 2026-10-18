import { Link, useParams } from "react-router-dom";
import { ChevronRight, FileQuestion } from "lucide-react";
import { ApiError } from "../api/client";
import ErrorFallback from "../components/ErrorFallback";
import ImportantBadge from "../components/ImportantBadge";
import MarkdownText from "../components/MarkdownText";
import PageLoadingFallback from "../components/PageLoadingFallback";
import SubpageLayout from "../components/SubpageLayout";
import { useNoticeDetail } from "../hooks/useNotices";
import { formatNoticeDate, NOTICE_LIST_PATH } from "../lib/noticePresentation";

// 공지 없음 응답 (없음·비활성·노출 전)
const NOTICE_NOT_FOUND_STATUS = 404;

/** 공지 상세: 중요 배지 > 제목 > 게시일 > 구분선 > 본문(마크다운) > 다른 공지 보기 (#529) */
export default function NoticeDetail() {
  const { noticeUuid = "" } = useParams();
  const notice = useNoticeDetail(noticeUuid);

  return (
    <SubpageLayout title="공지사항">
      <div className="max-w-2xl mx-auto">
        {notice.isLoading && <PageLoadingFallback />}
        {notice.isError &&
          (notice.error instanceof ApiError && notice.error.status === NOTICE_NOT_FOUND_STATUS ? (
            <div className="flex flex-col items-center gap-2 py-16 text-text-caption">
              <FileQuestion size={28} />
              <p className="text-sm">공지를 찾을 수 없어요</p>
            </div>
          ) : (
            <ErrorFallback onRetry={() => void notice.refetch()} />
          ))}
        {notice.data && (
          <article className="bg-surface-card border border-border rounded-2xl px-5 py-6 sm:px-8 sm:py-8">
            {notice.data.isImportant && (
              <div className="mb-3">
                <ImportantBadge />
              </div>
            )}
            <h1 className="text-h1 text-text-primary break-keep">{notice.data.title}</h1>
            <p className="mt-2 text-sm text-text-caption tabular-nums">
              <time dateTime={notice.data.publishedAt}>{formatNoticeDate(notice.data.publishedAt)}</time>
            </p>
            <hr className="my-6 border-border" />
            <MarkdownText text={notice.data.body} className="text-text-primary break-keep" />
          </article>
        )}
        {!notice.isLoading && (
          <Link
            to={NOTICE_LIST_PATH}
            className="mt-4 flex items-center justify-center gap-1 py-3 text-sm font-semibold text-brand hover:underline"
          >
            다른 공지 보기
            <ChevronRight size={16} />
          </Link>
        )}
      </div>
    </SubpageLayout>
  );
}
