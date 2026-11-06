import { RefreshCw, Sparkles } from "lucide-react";
import ProAccessReasonContent from "../pro/ProAccessReasonContent";
import { toChoiceGenerationErrorMessage, type ChoiceGenerationError } from "../../lib/choiceGenerationError";
import { toProAccessErrorCodeFromErrorCode } from "../../lib/proAccess";

interface ChoiceGenerationStatusProps {
  readonly generationError: ChoiceGenerationError | null;
  readonly onRetry: () => void;
}

/**
 * 선택지가 아직 없을 때: AI 생성 중 / 한도·프로 필요 사유 / 그 외 오류 문구 + 재시도 (EXECUTABLE, CONCEPT_ONLY 공통)
 */
export default function ChoiceGenerationStatus({ generationError, onRetry }: ChoiceGenerationStatusProps) {
  // 하루 한도·프로 필요 > 사유 본문 (다시 시도해도 같은 거부라 재시도 없음, #881)
  const proAccessErrorCode = toProAccessErrorCodeFromErrorCode(generationError?.code);
  if (proAccessErrorCode) {
    return (
      <div role="status" className="mt-4 bg-surface-card border border-border rounded-2xl py-8 px-6">
        <ProAccessReasonContent errorCode={proAccessErrorCode} />
      </div>
    );
  }

  return (
    <div className="mt-4 bg-surface-card border border-border rounded-2xl text-center py-8 space-y-2">
      {generationError ? (
        <>
          <p className="text-text-caption text-sm break-keep px-6">{toChoiceGenerationErrorMessage(generationError)}</p>
          {generationError.isRetryable && (
            <button
              type="button"
              className="flex items-center gap-1.5 mx-auto text-brand text-sm font-medium"
              onClick={onRetry}
            >
              <RefreshCw size={14} />
              다시 시도
            </button>
          )}
        </>
      ) : (
        <>
          {/* Sparkles pulse-fast — AI 선택지 생성 중, 기본 pulse보다 1.5배 빠른 반짝임 */}
          <Sparkles
            size={28}
            className="mx-auto text-brand animate-pulse-fast"
            fill="currentColor"
          />
          <p className="text-text-caption text-sm">
            AI가 선택지를 만들고 있어요
          </p>
        </>
      )}
    </div>
  );
}
