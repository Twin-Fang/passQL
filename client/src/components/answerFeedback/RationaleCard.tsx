import { FileText, Sparkles } from "lucide-react";
import MarkdownText from "../MarkdownText";

interface RationaleCardProps {
  readonly rationale: string;
  // 미리 생성된 AI 해설이면 머리를 AI 해설로 (#496)
  readonly isAiExplanation?: boolean;
}

/**
 * 해설 카드 — acc-sql-card와 동일한 10px 라운드로 통일
 */
export default function RationaleCard({ rationale, isAiExplanation = false }: RationaleCardProps) {
  const HeaderIcon = isAiExplanation ? Sparkles : FileText;
  return (
    <div className="rationale-card feedback-card-anim-2">
      <div className="flex items-center gap-1.5 mb-2">
        <HeaderIcon size={13} className="text-base-content/60 shrink-0" />
        <p className="text-xs text-base-content/60 uppercase tracking-widest font-semibold">
          {isAiExplanation ? "AI 해설" : "해설"}
        </p>
      </div>
      <MarkdownText text={rationale} className="text-sm text-base-content leading-relaxed" />
    </div>
  );
}
