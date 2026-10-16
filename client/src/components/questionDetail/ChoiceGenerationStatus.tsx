import { RefreshCw, Sparkles } from "lucide-react";
import type { ChoiceGenerationError } from "../../hooks/useQuestionChoices";

interface ChoiceGenerationStatusProps {
  readonly generationError: ChoiceGenerationError | null;
  readonly onRetry: () => void;
}

/** 에러 코드 > 사용자 메시지 (TIMEOUT, STREAM_CLOSED, 그 외) */
function toGenerationErrorMessage(code: string): string {
  if (code === "TIMEOUT") return "선택지 생성 시간이 초과되었어요";
  if (code === "STREAM_CLOSED") return "서버 연결이 예기치 않게 끊겼어요";
  return "선택지 생성에 실패했어요";
}

/**
 * 선택지가 아직 없을 때: AI 생성 중 표시 또는 SSE 에러 + 재시도 (EXECUTABLE, CONCEPT_ONLY 공통)
 */
export default function ChoiceGenerationStatus({ generationError, onRetry }: ChoiceGenerationStatusProps) {
  return (
    <div className="mt-4 bg-surface-card border border-border rounded-2xl text-center py-8 space-y-2">
      {generationError ? (
        <>
          <p className="text-text-caption text-sm">{toGenerationErrorMessage(generationError.code)}</p>
          {generationError.retryable && (
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
