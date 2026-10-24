import { useState, useRef, useEffect } from "react";
import { HelpCircle } from "lucide-react";
import type { TopicStat } from "../types/api";
import AnchoredPopover from "./AnchoredPopover";
import ProgressBar from "./ProgressBar";
import { toCorrectRateTone, type CorrectRateTone } from "../constants/correctRateTone";

interface StatsTopicListProps {
  readonly topicStats: readonly TopicStat[];
}

// 정답률 구간 > 뱃지·막대 색 클래스
const RATE_COLOR_CLASS_BY_TONE: Readonly<Record<CorrectRateTone, { badge: string; bar: string }>> = {
  success: { badge: "text-semantic-success-text bg-semantic-success-light", bar: "bg-semantic-success" },
  brand: { badge: "text-brand bg-brand-light", bar: "bg-brand" },
  warning: { badge: "text-semantic-warning-text bg-semantic-warning-light", bar: "bg-semantic-warning" },
  error: { badge: "text-semantic-error-text bg-semantic-error-light", bar: "bg-semantic-error" },
};

// ? 팝오버 폭 (px)
const TOPIC_LIST_POPOVER_WIDTH_PIXELS = 240;

function TopicListPopover({
  open,
  anchorRef,
}: {
  open: boolean;
  anchorRef: React.RefObject<HTMLButtonElement | null>;
}) {
  return (
    <AnchoredPopover isOpen={open} anchorRef={anchorRef} widthPixels={TOPIC_LIST_POPOVER_WIDTH_PIXELS} alignment="start">
      <p className="text-xs font-bold mb-2">어떻게 보나요?</p>
      <div className="flex flex-col gap-2">
        <div className="flex items-start gap-2">
          <div className="w-2 h-2 rounded-sm bg-brand mt-0.5 shrink-0" />
          <p className="text-xs text-text-inverse-secondary leading-relaxed">
            <span className="text-text-inverse font-semibold">막대 길이</span> — 해당 토픽을 얼마나 많이 풀었는지 나타내요
          </p>
        </div>
        <div className="flex items-start gap-2">
          <div className="w-2 h-2 rounded-sm bg-semantic-error mt-0.5 shrink-0" />
          <p className="text-xs text-text-inverse-secondary leading-relaxed">
            <span className="text-text-inverse font-semibold">색상 뱃지</span> — 정답률을 나타내요. 빨간색일수록 취약한 영역이에요
          </p>
        </div>
      </div>
    </AnchoredPopover>
  );
}

// 범례 항목
const LEGEND = [
  { color: "bg-semantic-success", label: "80%↑" },
  { color: "bg-brand",       label: "60%↑" },
  { color: "bg-semantic-warning", label: "40%↑" },
  { color: "bg-semantic-error",   label: "취약" },
] as const;

export default function StatsTopicList({ topicStats }: StatsTopicListProps) {
  const [popoverOpen, setPopoverOpen] = useState(false);
  const buttonRef = useRef<HTMLButtonElement>(null);

  // 바깥 클릭 시 팝오버 닫기
  useEffect(() => {
    if (!popoverOpen) return;
    const handler = (e: MouseEvent) => {
      if (buttonRef.current?.contains(e.target as Node)) return;
      setPopoverOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [popoverOpen]);

  // 막대 길이 기준 — 전체 토픽 중 가장 많이 푼 문제 수
  const maxSolved = Math.max(...topicStats.map((s) => s.solvedCount), 1);

  return (
    <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6">
      {/* 헤더 + ? 버튼 */}
      <div className="flex items-center gap-1.5 mb-4">
        <h2 className="text-base font-bold text-text-primary">토픽별 학습 현황</h2>
        <button
          ref={buttonRef}
          onClick={() => setPopoverOpen((v) => !v)}
          className="w-4 h-4 rounded-full bg-surface-code flex items-center justify-center shrink-0"
          aria-label="토픽별 학습 현황 설명"
        >
          <HelpCircle size={10} className="text-text-caption" />
        </button>
        <TopicListPopover open={popoverOpen} anchorRef={buttonRef} />
      </div>

      {/* 토픽 목록 */}
      <div className="flex flex-col gap-3.5">
        {topicStats.map((stat) => {
          const unsolved = stat.solvedCount === 0;
          const colors = unsolved ? null : RATE_COLOR_CLASS_BY_TONE[toCorrectRateTone(stat.correctRate)];
          const barWidth = unsolved ? 0 : Math.round((stat.solvedCount / maxSolved) * 100);

          return (
            <div key={stat.topicUuid}>
              <div className="flex justify-between items-center mb-1.5">
                <span className={`text-footnote font-medium ${unsolved ? "text-text-caption" : "text-text-primary"}`}>
                  {stat.displayName}
                </span>
                {unsolved ? (
                  <span className="text-caption1 text-border">미학습</span>
                ) : (
                  <div className="flex items-center gap-2">
                    <span className="text-caption1 text-text-caption">{stat.solvedCount}문제</span>
                    <span className={`text-caption2 font-semibold px-1.5 py-px rounded-full ${colors!.badge}`}>
                      {Math.round(stat.correctRate * 100)}%
                    </span>
                  </div>
                )}
              </div>
              {/* 진행 바 — 미학습은 빈 트랙 */}
              <ProgressBar
                fillPercent={barWidth}
                trackClassName="h-2 bg-surface-code"
                fillClassName={colors ? `transition-all duration-500 ${colors.bar}` : ""}
              />
            </div>
          );
        })}
      </div>

      {/* 범례 */}
      <div className="flex gap-3 mt-5 pt-4 border-t border-border">
        {LEGEND.map(({ color, label }) => (
          <div key={label} className="flex items-center gap-1">
            <div className={`w-2 h-2 rounded-sm ${color}`} />
            <span className="text-caption2 text-text-caption">{label}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
