import { ChevronLeft, ChevronRight, Flag, LayoutGrid } from "lucide-react";

interface MockExamSolvingBottomBarProps {
  readonly hasPreviousQuestion: boolean;
  readonly hasNextQuestion: boolean;
  readonly isFlagged: boolean;
  readonly unansweredCount: number;
  readonly isSubmitting: boolean;
  readonly onPreviousPressed: () => void;
  readonly onNextPressed: () => void;
  readonly onFlagPressed: () => void;
  readonly onPaletteOpenPressed: () => void;
  readonly onSubmitPressed: () => void;
}

/**
 * 풀이 하단 바: 1줄(이전·표시·다음) + 2줄(번호판·제출)
 * 표시 버튼은 눌림 상태(aria-pressed)로 낭독
 */
export default function MockExamSolvingBottomBar({
  hasPreviousQuestion,
  hasNextQuestion,
  isFlagged,
  unansweredCount,
  isSubmitting,
  onPreviousPressed,
  onNextPressed,
  onFlagPressed,
  onPaletteOpenPressed,
  onSubmitPressed,
}: MockExamSolvingBottomBarProps) {
  return (
    <div className="fixed bottom-0 inset-x-0 z-20 bg-surface-card border-t border-border">
      <div className="mx-auto max-w-120 px-4 pt-3 pb-4 space-y-2">
        <div className="grid grid-cols-3 gap-2">
          <button type="button" className="btn btn-ghost gap-1" disabled={!hasPreviousQuestion} onClick={onPreviousPressed}>
            <ChevronLeft size={18} aria-hidden="true" />
            이전
          </button>
          <button
            type="button"
            aria-pressed={isFlagged}
            className={`btn gap-1 ${isFlagged ? "bg-semantic-warning-light text-semantic-warning-text border-semantic-warning-border" : "btn-ghost"}`}
            onClick={onFlagPressed}
          >
            <Flag size={16} aria-hidden="true" fill={isFlagged ? "currentColor" : "none"} />
            표시
          </button>
          <button type="button" className="btn btn-ghost gap-1" disabled={!hasNextQuestion} onClick={onNextPressed}>
            다음
            <ChevronRight size={18} aria-hidden="true" />
          </button>
        </div>
        <div className="grid grid-cols-2 gap-2">
          <button
            type="button"
            aria-label={`번호판 열기, 안 푼 문항 ${unansweredCount}개`}
            className="btn btn-secondary gap-1.5 whitespace-nowrap"
            onClick={onPaletteOpenPressed}
          >
            <LayoutGrid size={16} aria-hidden="true" />
            번호판
            <span aria-hidden="true" className="badge badge-sm border-0 bg-brand-light text-brand tabular-nums">
              {unansweredCount}
            </span>
          </button>
          <button type="button" className="btn btn-primary" disabled={isSubmitting} onClick={onSubmitPressed}>
            {isSubmitting && <span className="loading loading-spinner loading-sm" />}
            제출하기
          </button>
        </div>
      </div>
    </div>
  );
}
