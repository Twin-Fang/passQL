import { FileText } from "lucide-react";
import MarkdownText from "../MarkdownText";

interface RationaleCardProps {
  readonly rationale: string;
}

/**
 * 해설 카드 — acc-sql-card와 동일한 10px 라운드로 통일
 */
export default function RationaleCard({ rationale }: RationaleCardProps) {
  return (
    <div className="rationale-card feedback-card-anim-2">
      <div className="flex items-center gap-1.5 mb-2">
        <FileText size={13} className="text-base-content/60 shrink-0" />
        <p className="text-xs text-base-content/60 uppercase tracking-widest font-semibold">해설</p>
      </div>
      <MarkdownText text={rationale} className="text-sm text-base-content leading-relaxed" />
    </div>
  );
}
