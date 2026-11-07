import { useEffect, useRef, useState } from "react";
import { BadgeCheck, ChevronDown, Zap } from "lucide-react";
import ChoiceModeSheet from "../choiceMode/ChoiceModeSheet";
import { useEffectiveChoiceMode } from "../../hooks/useEffectiveChoiceMode";
import {
  FRESH_CHOICE_MODE,
  isAppliedToCurrentQuestion,
  toEffectiveChoiceMode,
  type ChoiceModeSwitchAction,
} from "../../lib/choiceModeSwitchPlan";
import { APPLIES_FROM_NEXT_SOLVE_NOTICE, CHOICE_MODE_SHORT_NAME } from "../../constants/choiceModeCopy";
import type { ChoiceGenerationMode } from "../../types/api";

// 다음 풀이부터 적용 안내 표시 시간 (2.5초)
const NEXT_SOLVE_NOTICE_VISIBLE_MILLISECONDS = 2500;

interface ChoiceModeChipProps {
  // 이 풀이를 제출했는지 (시트 안내 문구, 적용 판정)
  readonly hasSubmissionStarted: boolean;
  // 저장된 새 방식(실효 모드)을 지금 문제에 반영하고 한 일을 돌려줌
  readonly onModeChanged: (targetMode: ChoiceGenerationMode) => ChoiceModeSwitchAction;
}

/**
 * 풀이 화면 보기 방식 칩 (#913, 앱 ChoiceModeIndicator 대응): 지금 방식 알약 > 시트 > 지금 문제에 반영 (제출 뒤면 다음 풀이부터 안내)
 * 실효 모드로 표시 (무료는 검증된 보기), 모드를 모르면 숨김
 */
export default function ChoiceModeChip({ hasSubmissionStarted, onModeChanged }: ChoiceModeChipProps) {
  const { effectiveMode, shouldShowProUi } = useEffectiveChoiceMode();
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const [isNextSolveNoticeVisible, setIsNextSolveNoticeVisible] = useState(false);
  const noticeTimerIdRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // 화면 이탈 시 안내 타이머 정리
  useEffect(() => {
    return () => {
      if (noticeTimerIdRef.current !== null) clearTimeout(noticeTimerIdRef.current);
    };
  }, []);

  if (effectiveMode == null) return null;

  /** 저장 성공 > 시트 닫기 > 지금 문제에 반영 > 반영 못 했으면 다음 풀이부터 안내 */
  const handleModeSaved = (savedMode: ChoiceGenerationMode) => {
    setIsSheetOpen(false);
    const action = onModeChanged(toEffectiveChoiceMode(savedMode, shouldShowProUi));
    if (isAppliedToCurrentQuestion(action)) return;
    setIsNextSolveNoticeVisible(true);
    if (noticeTimerIdRef.current !== null) clearTimeout(noticeTimerIdRef.current);
    noticeTimerIdRef.current = setTimeout(
      () => setIsNextSolveNoticeVisible(false),
      NEXT_SOLVE_NOTICE_VISIBLE_MILLISECONDS,
    );
  };

  const isFreshChoices = effectiveMode === FRESH_CHOICE_MODE;
  const ModeIcon = isFreshChoices ? Zap : BadgeCheck;
  const modeShortName = CHOICE_MODE_SHORT_NAME[effectiveMode];

  return (
    <>
      {/* 바깥 버튼은 터치 영역(44px), 안쪽 알약이 보이는 칩 */}
      <button
        type="button"
        aria-haspopup="dialog"
        aria-label={`보기 방식 ${modeShortName}, 바꾸기`}
        onClick={() => setIsSheetOpen(true)}
        className="mt-2 -mb-2 self-start inline-flex items-center min-h-11 cursor-pointer"
      >
        <span
          className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold ${
            isFreshChoices ? "bg-brand-light text-brand" : "bg-surface-card border border-border text-text-secondary"
          }`}
        >
          <ModeIcon size={14} aria-hidden="true" />
          {modeShortName}
          <ChevronDown size={12} aria-hidden="true" />
        </span>
      </button>
      {isSheetOpen && (
        <ChoiceModeSheet
          hasSubmissionStarted={hasSubmissionStarted}
          onClose={() => setIsSheetOpen(false)}
          onModeSaved={handleModeSaved}
        />
      )}
      {isNextSolveNoticeVisible && (
        <div role="status" className="fixed top-4 inset-x-0 z-50 flex justify-center px-4 pointer-events-none">
          <p className="bg-surface-inverse text-text-inverse text-sm font-medium px-4 py-2.5 rounded-lg text-center break-keep">
            {APPLIES_FROM_NEXT_SOLVE_NOTICE}
          </p>
        </div>
      )}
    </>
  );
}
