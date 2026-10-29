import { useEffect, useRef, useState } from "react";
import { fetchLegal, LEGAL_TITLE, type LegalType } from "../api/legal";
import MarkdownText from "./MarkdownText";

/**
 * 약관 본문 모달 (로그인·설정 공통, #658): 서버 공개 약관 조회 > 마크다운 표시, 실패 시 다시 시도
 * daisyUI 반응형 모달 — 모바일 하단 시트, 데스크톱 중앙
 */
export default function LegalModal({
  type,
  onClose,
}: {
  readonly type: LegalType;
  readonly onClose: () => void;
}) {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [title, setTitle] = useState<string | null>(null);
  const [content, setContent] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [fetchError, setFetchError] = useState(false);

  // 모달 열기 + 닫힐 때 onClose 연동
  // open 체크: onClose 참조 변경 시 재실행되어도 이미 열린 dialog에 showModal 중복 호출 방지
  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (!dialog.open) dialog.showModal();
    const handleClose = () => onClose();
    dialog.addEventListener("close", handleClose);
    return () => dialog.removeEventListener("close", handleClose);
  }, [onClose]);

  // 다시 시도 버튼이 값을 올려 같은 type으로 재요청하게 한다
  const [retryKey, setRetryKey] = useState(0);

  // 약관 내용 fetch — 모달이 닫혀 언마운트되면 늦게 온 응답은 버린다
  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);
    setFetchError(false);
    fetchLegal(type)
      .then((data) => {
        if (cancelled) return;
        setTitle(data.title);
        setContent(data.content);
      })
      .catch(() => {
        if (!cancelled) setFetchError(true);
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [type, retryKey]);

  return (
    <dialog ref={dialogRef} className="modal modal-bottom sm:modal-middle">
      <div className="modal-box flex flex-col max-h-[80vh] p-0 overflow-hidden">
        {/* 헤더 */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-border shrink-0">
          <h3 className="text-base font-bold text-text-primary">
            {/* 실패해도 사용자가 연 문서 이름을 보여 준다 (#403) */}
            {title ?? LEGAL_TITLE[type]}
          </h3>
          <form method="dialog">
            <button
              type="submit"
              className="btn btn-sm btn-circle btn-ghost text-text-caption"
              aria-label="닫기"
            >
              ✕
            </button>
          </form>
        </div>

        {/* 본문 스크롤 영역 */}
        <div className="overflow-y-auto px-5 py-4 flex-1">
          {isLoading && (
            <div className="flex justify-center py-8">
              <span className="loading loading-spinner loading-md text-brand" />
            </div>
          )}
          {fetchError && (
            <div className="flex flex-col items-center gap-3 py-8">
              <p className="text-sm text-semantic-error text-center">
                {LEGAL_TITLE[type]}을 불러오지 못했습니다.
              </p>
              <button
                type="button"
                className="btn btn-sm btn-outline border-brand text-brand hover:bg-brand-light hover:border-brand"
                onClick={() => setRetryKey((k) => k + 1)}
              >
                다시 시도
              </button>
            </div>
          )}
          {!isLoading && !fetchError && content && (
            <div className="prose prose-sm max-w-none text-text-primary">
              <MarkdownText text={content} animated={false} />
            </div>
          )}
          <div className="h-4" />
        </div>
      </div>
      {/* 오버레이 클릭 시 닫기 */}
      <form method="dialog" className="modal-backdrop">
        <button type="submit">닫기</button>
      </form>
    </dialog>
  );
}
