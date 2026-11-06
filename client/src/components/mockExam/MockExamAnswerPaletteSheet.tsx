import { useEffect, useRef } from "react";
import { X } from "lucide-react";
import MockExamQuestionNumberGrid from "./MockExamQuestionNumberGrid";
import type { QuestionNumberCell, SubjectGroup } from "../../lib/mockExamPresentation";

interface MockExamAnswerPaletteSheetProps {
  readonly isOpen: boolean;
  readonly groups: readonly SubjectGroup<QuestionNumberCell>[];
  readonly unansweredCount: number;
  readonly flaggedCount: number;
  readonly onSelectQuestion: (questionNumber: number) => void;
  readonly onClose: () => void;
}

/**
 * 풀이 번호판 시트: 안 푼·표시 문항 수 > 범례 > 과목별 번호판 (번호 누르면 이동하고 닫힘)
 * 열리면 닫기 버튼에 포커스, ESC·바깥 누르면 닫힘, 닫히면 연 버튼으로 포커스 복귀
 */
export default function MockExamAnswerPaletteSheet({
  isOpen,
  groups,
  unansweredCount,
  flaggedCount,
  onSelectQuestion,
  onClose,
}: MockExamAnswerPaletteSheetProps) {
  const closeButtonRef = useRef<HTMLButtonElement>(null);

  // 열림: 포커스 이동 + ESC 닫기, 닫힘: 이전 포커스 복귀
  useEffect(() => {
    if (!isOpen) return;
    const previouslyFocusedElement = document.activeElement as HTMLElement | null;
    closeButtonRef.current?.focus();
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => {
      window.removeEventListener("keydown", onKeyDown);
      previouslyFocusedElement?.focus();
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-scrim" onClick={onClose}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="mock-exam-palette-title"
        className="w-full sm:max-w-120 max-h-[85vh] overflow-y-auto bg-surface-card border border-border rounded-t-2xl sm:rounded-2xl px-5 pt-4 pb-8"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex items-center justify-between mb-1">
          <h2 id="mock-exam-palette-title" className="text-lg font-bold text-text-primary">
            문항 번호판
          </h2>
          <button
            ref={closeButtonRef}
            type="button"
            aria-label="번호판 닫기"
            className="btn btn-ghost btn-sm btn-square"
            onClick={onClose}
          >
            <X size={18} aria-hidden="true" />
          </button>
        </div>
        <p className="text-sm text-text-secondary mb-3">
          안 푼 문항 <strong className="text-text-primary">{unansweredCount}개</strong> · 표시한 문항{" "}
          <strong className="text-text-primary">{flaggedCount}개</strong>
        </p>

        {/* 범례: 답함·안 품·표시·현재 */}
        <ul className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-text-secondary mb-4" aria-label="번호판 범례">
          <li className="flex items-center gap-1.5">
            <span aria-hidden="true" className="w-3 h-3 rounded bg-brand" />
            답함
          </li>
          <li className="flex items-center gap-1.5">
            <span aria-hidden="true" className="w-3 h-3 rounded border border-border bg-surface-card" />안 품
          </li>
          <li className="flex items-center gap-1.5">
            <span aria-hidden="true" className="w-1.5 h-1.5 rounded-full bg-semantic-warning" />
            표시
          </li>
          <li className="flex items-center gap-1.5">
            <span aria-hidden="true" className="w-3 h-3 rounded ring-2 ring-brand" />
            지금 문항
          </li>
        </ul>

        <MockExamQuestionNumberGrid groups={groups} onSelectQuestion={onSelectQuestion} />
      </div>
    </div>
  );
}
