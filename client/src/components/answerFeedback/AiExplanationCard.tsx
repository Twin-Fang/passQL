import { Sparkles } from "lucide-react";
import ExplanationBody from "../aiExplanation/ExplanationBody";
import type { ExplanationHistoryEntry } from "../../stores/explanationHistoryStore";

interface AiExplanationCardProps {
  readonly entry: ExplanationHistoryEntry;
}

/**
 * 단건 결과 화면 AI 해설: 머리 + 해설 본문 인라인 (다음 문제가 없어 패널 대신 본문에 펼침, #521)
 */
export default function AiExplanationCard({ entry }: AiExplanationCardProps) {
  return (
    <section className="rationale-card feedback-card-anim-2" aria-label="AI 해설">
      <div className="flex items-center gap-1.5 mb-3">
        <Sparkles size={13} className="text-brand shrink-0" />
        <h2 className="text-xs text-brand font-semibold">AI 해설</h2>
      </div>
      <ExplanationBody entry={entry} />
    </section>
  );
}
