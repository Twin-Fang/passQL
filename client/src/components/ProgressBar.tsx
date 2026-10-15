import { useRef } from "react";
import { useCssVariables } from "../hooks/useCssVariables";

interface ProgressBarProps {
  // 채움 비율 (0~100, 범위 밖은 잘라냄)
  readonly fillPercent: number;
  // 트랙 높이·배경·여백 (예: "h-1.5 bg-border")
  readonly trackClassName: string;
  // 채움 색·전환 (예: "bg-brand transition-all duration-300")
  readonly fillClassName: string;
}

/** 가로 진행 막대: 트랙 + 비율만큼 채운 막대 */
export default function ProgressBar({ fillPercent, trackClassName, fillClassName }: ProgressBarProps) {
  const fillRef = useRef<HTMLDivElement>(null);
  const clampedFillPercent = Math.min(100, Math.max(0, fillPercent));
  useCssVariables(fillRef, { "--progress-fill": `${clampedFillPercent}%` });

  return (
    <div className={`w-full rounded-full overflow-hidden ${trackClassName}`}>
      <div ref={fillRef} className={`h-full rounded-full [width:var(--progress-fill)] ${fillClassName}`} />
    </div>
  );
}
