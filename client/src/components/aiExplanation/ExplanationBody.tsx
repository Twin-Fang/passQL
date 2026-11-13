import { RotateCw } from "lucide-react";
import MarkdownText from "../MarkdownText";
import ExplanationContent from "./ExplanationContent";
import ExplanationSkeleton from "./ExplanationSkeleton";
import { useChoiceExplanation } from "../../hooks/useChoiceExplanation";
import { useMemberPlan } from "../../hooks/useMemberPlan";
import { isFullExplanationLocked } from "../../lib/proAccess";
import { shouldShowVerdictOnly, toVerdictOnlyExplanation } from "../../lib/choiceExplanationPresentation";
import type { ExplanationHistoryEntry } from "../../stores/explanationHistoryStore";

interface ExplanationBodyProps {
  readonly entry: ExplanationHistoryEntry;
}

/**
 * 해설 1건 전체 본문: 기다림(스켈레톤·옛 해설 임시) > 구조화 해설 또는 마크다운 > 실패(재시도 + 폴백)
 * 무료(결제 켜짐) + 해설 묶음 잠김: 판정 아래 잠금 미리보기 (#578)
 * 판정까지 비어 오거나 폴백 없이 실패하면 제출 결과로 조립한 판정 + 잠금 미리보기 (#867)
 */
export default function ExplanationBody({ entry }: ExplanationBodyProps) {
  const explanationView = useChoiceExplanation(entry);
  const { shouldShowProUi } = useMemberPlan();
  const isExplanationLocked = shouldShowProUi && isFullExplanationLocked(explanationView.lockedSections);

  if (explanationView.phase === "loading") {
    return (
      <div className="space-y-3">
        <p className="text-xs text-text-secondary">AI가 해설을 정리하고 있어요</p>
        <ExplanationSkeleton />
        {/* 옛 해설이 있으면 기다리는 동안 먼저 보여 줌 */}
        {explanationView.markdownText && (
          <MarkdownText text={explanationView.markdownText} className="text-sm leading-relaxed text-text-primary opacity-80" />
        )}
      </div>
    );
  }

  // 무료 재제출 실패(근거 폴백 없음)·판정까지 빈 응답: 다시 시도 대신 판정 + 잠금 (풀려도 무료 몫은 판정뿐)
  const isFailedVerdictOnly =
    explanationView.phase === "failed" && shouldShowVerdictOnly(entry, shouldShowProUi, explanationView.markdownText);
  const isEmptyLocked = explanationView.phase === "ready" && !explanationView.explanation && isExplanationLocked;
  if (isFailedVerdictOnly || isEmptyLocked) {
    return (
      <ExplanationContent
        explanation={toVerdictOnlyExplanation(entry)}
        displayLabelByChoiceKey={entry.displayLabelByChoiceKey}
        isFullExplanationLocked
        basicExplanation={explanationView.basicExplanation}
      />
    );
  }

  if (explanationView.phase === "failed") {
    return (
      <div className="space-y-3">
        <div role="alert" className="flex items-center justify-between gap-3 rounded-xl bg-surface px-3.5 py-3">
          <p className="text-sm text-text-secondary">AI 해설을 불러오지 못했어요</p>
          <button type="button" className="btn btn-sm btn-ghost text-brand gap-1 shrink-0" onClick={explanationView.retry}>
            <RotateCw size={14} />
            다시 시도
          </button>
        </div>
        {explanationView.markdownText && (
          <MarkdownText text={explanationView.markdownText} className="text-sm leading-relaxed text-text-primary" />
        )}
      </div>
    );
  }

  if (explanationView.explanation) {
    return (
      <ExplanationContent
        explanation={explanationView.explanation}
        displayLabelByChoiceKey={entry.displayLabelByChoiceKey}
        isFullExplanationLocked={isExplanationLocked}
        basicExplanation={explanationView.basicExplanation}
      />
    );
  }
  // 고정 세트·옛 해설: 마크다운 본문
  return <MarkdownText text={explanationView.markdownText ?? ""} className="text-sm leading-relaxed text-text-primary" />;
}
