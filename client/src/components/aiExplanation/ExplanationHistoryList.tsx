import { Check, ChevronRight, X } from "lucide-react";
import { useChoiceExplanation } from "../../hooks/useChoiceExplanation";
import type { ExplanationHistoryEntry } from "../../stores/explanationHistoryStore";

// 해설 상태 > 목록 보조 문구
const PHASE_LABEL = {
  loading: "정리 중",
  ready: "해설 보기",
  failed: "다시 시도 필요",
} as const;

interface ExplanationHistoryRowProps {
  readonly entry: ExplanationHistoryEntry;
  readonly isActive: boolean;
  readonly onSelect: (entryId: string) => void;
}

/** 해설함 행 1개: 정오답 표시 + 문제 라벨 + 해설 상태 */
function ExplanationHistoryRow({ entry, isActive, onSelect }: ExplanationHistoryRowProps) {
  const { phase } = useChoiceExplanation(entry);
  return (
    <li>
      <button
        type="button"
        className={`w-full flex items-center gap-3 px-4 py-3 text-left transition-colors hover:bg-surface ${isActive ? "bg-brand-light" : ""}`}
        onClick={() => onSelect(entry.id)}
      >
        <span
          className={`w-6 h-6 shrink-0 rounded-full flex items-center justify-center ${
            entry.isCorrect ? "bg-semantic-success-light" : "bg-semantic-error-light"
          }`}
          aria-label={entry.isCorrect ? "정답" : "오답"}
        >
          {entry.isCorrect ? (
            <Check size={13} className="text-semantic-success-text" />
          ) : (
            <X size={13} className="text-semantic-error-text" />
          )}
        </span>
        <span className="flex-1 text-sm font-semibold text-text-primary">{entry.questionLabel}</span>
        <span className="text-xs text-text-secondary">{PHASE_LABEL[phase]}</span>
        <ChevronRight size={14} className="text-text-caption" />
      </button>
    </li>
  );
}

interface ExplanationHistoryListProps {
  readonly entries: readonly ExplanationHistoryEntry[];
  readonly activeEntryId: string | null;
  readonly onSelect: (entryId: string) => void;
}

/**
 * 해설함: 이번 풀이에서 본 해설 최근 순 목록 > 누르면 그 해설
 */
export default function ExplanationHistoryList({ entries, activeEntryId, onSelect }: ExplanationHistoryListProps) {
  if (entries.length === 0) {
    return <p className="px-4 py-8 text-center text-sm text-text-secondary">아직 해설이 없어요</p>;
  }
  return (
    <ul className="divide-y divide-border" aria-label="해설함">
      {entries.map((entry) => (
        <ExplanationHistoryRow key={entry.id} entry={entry} isActive={entry.id === activeEntryId} onSelect={onSelect} />
      ))}
    </ul>
  );
}
