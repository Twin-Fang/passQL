import { X } from "lucide-react";
import FreshChoicesToggleRow from "./FreshChoicesToggleRow";
import { useCloseOnEscape } from "../../hooks/useCloseOnEscape";
import {
  APPLIES_FROM_NEXT_SOLVE_NOTICE,
  APPLIES_TO_CURRENT_QUESTION_NOTICE,
  CHOICE_MODE_SHEET_TITLE,
} from "../../constants/choiceModeCopy";
import type { ChoiceGenerationMode } from "../../types/api";

interface ChoiceModeSheetProps {
  // 이 풀이를 제출했는지 (아래 안내 문구)
  readonly hasSubmissionStarted: boolean;
  readonly onClose: () => void;
  // 저장 성공 뒤 (닫기 + 지금 문제에 반영은 호출부)
  readonly onModeSaved: (savedMode: ChoiceGenerationMode) => void;
}

/**
 * 풀이 화면 보기 방식 시트 (#913, 앱 choice_mode_sheet.dart 대응): 설정과 같은 새 보기로 풀기 스위치 한 줄 + 언제부터 적용인지
 * 모바일 하단 시트, 데스크톱 가운데 창 (AiExplanationSheet 와 같은 틀)
 */
export default function ChoiceModeSheet({ hasSubmissionStarted, onClose, onModeSaved }: ChoiceModeSheetProps) {
  useCloseOnEscape(onClose);

  return (
    <>
      <div className="dialog-overlay" onClick={onClose} />
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="choice-mode-sheet-title"
        className="fixed inset-x-0 bottom-0 md:inset-auto md:top-1/2 md:left-1/2 md:-translate-x-1/2 md:-translate-y-1/2 md:w-120 z-50 animate-sheet-slide-up-mobile"
      >
        <div className="bg-surface-card rounded-t-2xl md:rounded-xl max-h-[90vh] overflow-y-auto pb-4">
          <div className="md:hidden flex justify-center pt-3">
            <div className="w-10 h-1 rounded-full bg-border" />
          </div>
          <div className="flex items-center justify-between px-4 py-3">
            <h2 id="choice-mode-sheet-title" className="text-lg font-bold text-text-primary">
              {CHOICE_MODE_SHEET_TITLE}
            </h2>
            <button
              type="button"
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center text-text-secondary hover:text-text-primary transition-colors"
              aria-label="닫기"
            >
              <X size={18} />
            </button>
          </div>
          <div className="mx-4 bg-surface border border-border rounded-2xl overflow-hidden">
            <FreshChoicesToggleRow onModeSaved={onModeSaved} />
          </div>
          <p className="px-5 pt-2 text-xs text-text-caption break-keep">
            {hasSubmissionStarted ? APPLIES_FROM_NEXT_SOLVE_NOTICE : APPLIES_TO_CURRENT_QUESTION_NOTICE}
          </p>
        </div>
      </div>
    </>
  );
}
