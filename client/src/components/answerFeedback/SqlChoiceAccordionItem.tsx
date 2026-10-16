import { AlertCircle, ChevronDown, RefreshCw } from "lucide-react";
import { ResultTable } from "../ResultTable";
import PlayIcon from "../PlayIcon";
import type { ChoiceItem, ExecuteResult } from "../../types/api";

interface SqlChoiceAccordionItemProps {
  readonly choice: ChoiceItem;
  readonly isAnswer: boolean;
  readonly isMyChoice: boolean;
  readonly isOpen: boolean;
  readonly isRunning: boolean;
  readonly cachedResult: ExecuteResult | undefined;
  readonly executionError: string | undefined;
  readonly onToggle: (key: string) => void;
  readonly onExecute: (choice: ChoiceItem) => void;
}

/** EXECUTABLE 선택지 카드 상태에 따른 클래스 반환 — A/B/C/D 키 레이블 없이 뱃지로만 구분 */
function getChoiceCardClass(isAnswer: boolean, isMyChoice: boolean): {
  cardClass: string;
  badgeClass: string;
  badgeText: string | null;
} {
  if (isAnswer && isMyChoice) {
    return {
      cardClass: "acc-sql-card is-correct",
      // text-success-content는 흰색이라 연초록 배경에서 안 보임 — 직접 초록 텍스트 지정
      badgeClass: "badge badge-sm border-0 bg-success/20 text-success",
      badgeText: "내 선택 · 정답",
    };
  }
  if (isAnswer) {
    return {
      cardClass: "acc-sql-card is-correct",
      badgeClass: "badge badge-sm border-0 bg-success/20 text-success",
      badgeText: "정답",
    };
  }
  if (isMyChoice) {
    return {
      cardClass: "acc-sql-card is-wrong",
      badgeClass: "badge badge-sm border-0 bg-error/20 text-error",
      badgeText: "내 선택",
    };
  }
  return {
    cardClass: "acc-sql-card",
    badgeClass: "",
    badgeText: null,
  };
}

/**
 * SQL 선택지 아코디언 1개: 헤더(뱃지·미리보기) > 본문(SQL·실행 버튼 또는 에러·결과 테이블)
 */
export default function SqlChoiceAccordionItem({
  choice,
  isAnswer,
  isMyChoice,
  isOpen,
  isRunning,
  cachedResult,
  executionError,
  onToggle,
  onExecute,
}: SqlChoiceAccordionItemProps) {
  const { cardClass, badgeClass, badgeText } = getChoiceCardClass(isAnswer, isMyChoice);

  return (
    <div className={cardClass}>
      {/* 아코디언 헤더 — 클릭으로 열기/닫기 */}
      <div
        className="acc-sql-header"
        onClick={() => onToggle(choice.key)}
      >
        {/* 뱃지 (정답/내 선택만 표시, 나머지는 없음) — 열림/닫힘 모두 표시 */}
        {badgeText && (
          <span className={`${badgeClass} shrink-0`}>{badgeText}</span>
        )}

        {/* SQL 미리보기 — 항상 표시 (열려도 컨텍스트 유지) */}
        <span className="acc-sql-preview">{choice.body}</span>

        {/* 실행 중 인디케이터 */}
        {isRunning && (
          <span className="text-xs text-base-content/40 shrink-0">실행 중…</span>
        )}

        <ChevronDown
          size={13}
          className={`text-base-content/30 shrink-0 ml-auto transition-transform duration-200 ${isOpen ? "rotate-180" : ""}`}
        />
      </div>

      {/* 아코디언 바디 — 열렸을 때만 표시 */}
      {isOpen && (
        <div className="acc-sql-body">
          {/* SQL 본문 코드 블록 */}
          <pre className="text-xs font-mono leading-relaxed whitespace-pre-wrap wrap-break-word mb-3 text-base-content bg-base-200 rounded-lg p-3">
            {choice.body}
          </pre>

          {/* 실행 에러 */}
          {executionError ? (
            <div className="error-card mt-2 flex items-start justify-between gap-3">
              <div className="flex items-start gap-2 min-w-0">
                <AlertCircle size={15} className="text-error shrink-0 mt-0.5" />
                <p className="text-sm text-error leading-snug wrap-break-word">{executionError}</p>
              </div>
              <button
                type="button"
                className="btn-run-all shrink-0"
                onClick={() => onExecute(choice)}
              >
                <RefreshCw size={8} />
                재시도
              </button>
            </div>
          ) : !cachedResult ? (
            /* 미실행 — 개별 실행 버튼 (btn-run-all과 동일 스타일) */
            <div className="flex justify-end">
              <button
                type="button"
                className="btn-run-all"
                onClick={() => onExecute(choice)}
                disabled={isRunning}
              >
                {!isRunning && <PlayIcon />}
                {isRunning ? "실행 중…" : "쿼리 실행"}
              </button>
            </div>
          ) : null}

          {/* 실행 결과 테이블 */}
          {cachedResult && <ResultTable result={cachedResult} />}
        </div>
      )}
    </div>
  );
}
