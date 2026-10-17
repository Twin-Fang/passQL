import { Link } from "react-router-dom";
import { RotateCcw, ChevronDown, ChevronUp } from "lucide-react";
import { formatDurationLabel } from "../../lib/formatDurationLabel";
import type { PracticeQuestionResult } from "../../types/api";

interface PracticeQuestionResultRowProps {
  readonly result: PracticeQuestionResult;
  // 1부터 시작하는 문제 번호
  readonly questionNumber: number;
  readonly stemPreview: string | undefined;
  readonly sessionId: string | undefined;
  readonly isOpen: boolean;
  readonly isVisible: boolean;
  readonly onToggle: () => void;
}

/**
 * 문제별 결과 아코디언 1행: 번호·지문·소요 시간·정오 > 펼침(지문, 내 답, 다시 풀기)
 */
export default function PracticeQuestionResultRow({
  result,
  questionNumber,
  stemPreview,
  sessionId,
  isOpen,
  isVisible,
  onToggle,
}: PracticeQuestionResultRowProps) {
  return (
    <div
      className={`border rounded-tile overflow-hidden transition-all duration-350 ease-out ${
        result.isCorrect
          ? "bg-semantic-success-light border-semantic-success-border"
          : "bg-semantic-error-light border-semantic-error-border"
      } ${isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-2"}`}
    >
      <button
        type="button"
        className="w-full flex items-center gap-3 p-3 text-left"
        onClick={onToggle}
      >
        <span
          className={`text-sm font-bold w-5 text-center shrink-0 ${result.isCorrect ? "text-semantic-success-text" : "text-semantic-error-text"}`}
        >
          {questionNumber}
        </span>
        <div className="flex-1 min-w-0">
          <p className="text-sm truncate">{stemPreview}</p>
          <p className="text-xs text-text-caption mt-0.5">
            {formatDurationLabel(result.durationMs)}
          </p>
        </div>
        <div className="flex items-center gap-1.5 shrink-0">
          <span className={`text-xs font-medium ${result.isCorrect ? "text-semantic-success-text" : "text-semantic-error-text"}`}>
            {result.isCorrect ? "정답" : "오답"}
          </span>
          {isOpen ? (
            <ChevronUp size={14} className="text-text-caption" />
          ) : (
            <ChevronDown
              size={14}
              className="text-text-caption"
            />
          )}
        </div>
      </button>
      <div
        className={`grid transition-all duration-300 ease-out ${isOpen ? "grid-rows-[1fr]" : "grid-rows-[0fr]"}`}
      >
        <div className="overflow-hidden">
          <div className={`px-3 pb-3 pt-2 border-t space-y-2 ${result.isCorrect ? "border-semantic-success-border" : "border-semantic-error-border"}`}>
            <p className="text-sm text-text-secondary leading-relaxed">
              {stemPreview}
            </p>
            <p
              className={`text-xs font-medium ${result.isCorrect ? "text-semantic-success-text" : "text-semantic-error-text"}`}
            >
              내 답: {result.selectedChoiceBody}
            </p>
            {/* 다시 풀기 — 정답/오답 모두 재도전 가능, 색상으로 구분 */}
            <Link
              to={`/recommendation/${result.questionUuid}`}
              state={{
                returnPath: `/practice/${sessionId}`,
                initialStep: 1,
              }}
              className={`inline-flex items-center justify-center gap-1.5 w-full text-sm font-bold text-on-brand rounded-lg h-9 mt-1 transition-opacity hover:opacity-90 ${
                result.isCorrect ? "bg-semantic-success" : "bg-semantic-error"
              }`}
            >
              <RotateCcw size={14} /> 다시 풀기
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
