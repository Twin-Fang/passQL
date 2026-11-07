import { useState } from "react";
import { Zap } from "lucide-react";
import LockedPreview from "../pro/LockedPreview";
import AppPassGuideModal from "../pro/AppPassGuideModal";
import { FreshChoicesLockedSample } from "../pro/lockedPreviewSamples";
import { useEffectiveChoiceMode } from "../../hooks/useEffectiveChoiceMode";
import { useUpdateChoiceGenerationMode } from "../../hooks/useMember";
import { FRESH_CHOICE_MODE, VERIFIED_CHOICE_MODE } from "../../lib/choiceModeSwitchPlan";
import { toUserErrorMessage } from "../../lib/userErrorMessage";
import { LOCKED_PREVIEW_CAPTIONS } from "../../constants/proAccessCopy";
import {
  CHOICE_MODE_DESCRIPTION,
  CHOICE_MODE_SAVE_FAILED_MESSAGE,
  FRESH_CHOICES_TITLE,
} from "../../constants/choiceModeCopy";
import type { ChoiceGenerationMode } from "../../types/api";

interface FreshChoicesToggleRowProps {
  // 저장 성공 뒤 할 일 (풀이 시트: 닫고 지금 문제에 반영). 설정 화면은 없음
  readonly onModeSaved?: (savedMode: ChoiceGenerationMode) => void;
}

/**
 * 새 보기로 풀기 스위치 (#913, 앱 ChoiceModeTile 대응): 켜면 REAL, 끄면 PRACTICE. 설정·풀이 보기 방식 시트 공용
 * 무료(결제 켜짐): 검증된 보기로 표시 + 잠금 미리보기, 켜면 저장 없이 앱 이용권 안내
 */
export default function FreshChoicesToggleRow({ onModeSaved }: FreshChoicesToggleRowProps) {
  const { effectiveMode, shouldShowProUi } = useEffectiveChoiceMode();
  const { mutateAsync: saveChoiceMode, isPending: isSaving } = useUpdateChoiceGenerationMode();
  const [saveErrorMessage, setSaveErrorMessage] = useState<string | null>(null);
  const [isPassGuideOpen, setIsPassGuideOpen] = useState(false);
  const isFreshChoices = effectiveMode === FRESH_CHOICE_MODE;

  /** 켜기·끄기: 무료가 켜면 이용권 안내 > 그 외 저장 (실패 사유 표시, 화면을 닫아도 반영은 그대로) */
  const switchFreshChoiceMode = async (shouldUseFreshChoices: boolean) => {
    if (shouldUseFreshChoices && shouldShowProUi) {
      setIsPassGuideOpen(true);
      return;
    }
    const nextMode = shouldUseFreshChoices ? FRESH_CHOICE_MODE : VERIFIED_CHOICE_MODE;
    setSaveErrorMessage(null);
    try {
      await saveChoiceMode(nextMode);
    } catch (error) {
      setSaveErrorMessage(toUserErrorMessage(error, CHOICE_MODE_SAVE_FAILED_MESSAGE));
      return;
    }
    onModeSaved?.(nextMode);
  };

  return (
    <div>
      <label className="flex items-center gap-3 px-4 py-3.5 cursor-pointer">
        <span className="w-8 h-8 rounded-tile bg-brand-light flex items-center justify-center shrink-0">
          <Zap size={16} className="text-brand" aria-hidden="true" />
        </span>
        <span className="flex-1 min-w-0">
          <span className="block text-sm font-medium text-text-primary">{FRESH_CHOICES_TITLE}</span>
          <span className="block text-xs text-text-caption mt-0.5 break-keep">
            {CHOICE_MODE_DESCRIPTION[isFreshChoices ? FRESH_CHOICE_MODE : VERIFIED_CHOICE_MODE]}
          </span>
        </span>
        {/* 불러오는 중에는 값을 모르므로 조작을 막음 */}
        <input
          type="checkbox"
          role="switch"
          className="toggle toggle-primary shrink-0"
          checked={isFreshChoices}
          disabled={effectiveMode == null || isSaving}
          onChange={(event) => void switchFreshChoiceMode(event.target.checked)}
        />
      </label>
      {saveErrorMessage && (
        <p role="alert" className="px-4 pb-3 text-xs text-semantic-error break-keep">
          {saveErrorMessage}
        </p>
      )}
      {shouldShowProUi && (
        <div className="px-4 pb-4">
          <LockedPreview preview={<FreshChoicesLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.freshChoices} />
        </div>
      )}
      {isPassGuideOpen && <AppPassGuideModal onClose={() => setIsPassGuideOpen(false)} />}
    </div>
  );
}
