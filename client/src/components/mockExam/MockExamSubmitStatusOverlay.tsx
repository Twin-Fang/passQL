import { MOCK_EXAM_SUBMIT_FAILED_MESSAGE, MOCK_EXAM_TIME_UP_MESSAGE } from "../../constants/mockExamCopy";

interface MockExamSubmitStatusOverlayProps {
  readonly isTimeUp: boolean;
  readonly isSubmitting: boolean;
  readonly hasSubmitFailed: boolean;
  readonly onRetryPressed: () => void;
}

/**
 * 제출 상태 표시: 제출 중·시간 끝 > 화면 가림(조작 차단), 직접 제출 실패 > 하단 안내 + 다시 시도
 * 시간 끝 제출 실패는 가림 유지 (더 풀 수 없음) + 다시 시도
 */
export default function MockExamSubmitStatusOverlay({
  isTimeUp,
  isSubmitting,
  hasSubmitFailed,
  onRetryPressed,
}: MockExamSubmitStatusOverlayProps) {
  const retryButton = (
    <button type="button" className="btn btn-primary btn-sm" onClick={onRetryPressed}>
      다시 제출하기
    </button>
  );

  if (isTimeUp || isSubmitting) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-scrim px-6">
        <div role="alertdialog" aria-modal="true" aria-label="답안 제출" className="w-full max-w-80 bg-surface-card border border-border rounded-2xl px-6 py-7 flex flex-col items-center gap-3 text-center">
          {hasSubmitFailed && !isSubmitting ? (
            <>
              <p className="text-sm text-text-primary break-keep" role="alert">
                {MOCK_EXAM_SUBMIT_FAILED_MESSAGE}
              </p>
              {retryButton}
            </>
          ) : (
            <>
              <span className="loading loading-spinner loading-md text-brand" aria-hidden="true" />
              <p className="text-sm text-text-primary break-keep" role="status">
                {isTimeUp ? MOCK_EXAM_TIME_UP_MESSAGE : "답안을 제출하고 있어요"}
              </p>
            </>
          )}
        </div>
      </div>
    );
  }

  if (!hasSubmitFailed) return null;
  return (
    <div className="fixed inset-x-0 bottom-32 z-30 px-4">
      <div role="alert" className="mx-auto max-w-120 bg-surface-card border border-semantic-error-border rounded-xl px-4 py-3 flex items-center gap-3">
        <p className="flex-1 text-sm text-semantic-error-text break-keep">{MOCK_EXAM_SUBMIT_FAILED_MESSAGE}</p>
        {retryButton}
      </div>
    </div>
  );
}
