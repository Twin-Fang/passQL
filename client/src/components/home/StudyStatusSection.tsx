import { Flame } from "lucide-react";
import { HeatmapCalendar } from "../HeatmapCalendar";
import HomeRetryButton from "./HomeRetryButton";
import type { HeatmapResponse } from "../../types/api";

interface StudyStatusSectionProps {
  readonly streakDays: number;
  readonly heatmap: HeatmapResponse | undefined;
  readonly isHeatmapLoading: boolean;
  readonly isHeatmapError: boolean;
  readonly onRetryHeatmap: () => void;
  readonly staggerClassName: string;
}

/**
 * 홈 학습 현황: 연속 학습 뱃지 + 히트맵 (heatmap 에러/로딩만 독립 처리)
 */
export default function StudyStatusSection({
  streakDays,
  heatmap,
  isHeatmapLoading,
  isHeatmapError,
  onRetryHeatmap,
  staggerClassName,
}: StudyStatusSectionProps) {
  return (
    <section className={`bg-surface-card border border-border rounded-2xl p-4 sm:p-6 mb-4 ${staggerClassName}`}>
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-sm text-text-secondary">학습 현황</h2>
        {/* streak는 progress 에러 시 0 fallback → 뱃지 자연스럽게 미표시 */}
        {streakDays > 0 && (
          <span className="inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-bold bg-semantic-warning-light text-semantic-warning-text">
            {/* fill 속성으로 불꽃 아이콘을 꽉 채운 스타일로 표시 */}
            <Flame size={14} fill="currentColor" />
            연속 {streakDays}일
          </span>
        )}
      </div>

      {/* 히트맵: 에러 시 해당 영역만 인라인 에러 표시 */}
      {isHeatmapLoading ? (
        <div className="skeleton h-16" />
      ) : isHeatmapError ? (
        /* 히트맵 영역만 실패 — 카드 구조는 유지하고 영역 안에서 재시도 유도 */
        <div className="flex flex-col items-center gap-2 py-4 text-center">
          <p className="text-sm text-text-caption">히트맵을 불러올 수 없습니다</p>
          <HomeRetryButton onRetry={onRetryHeatmap} />
        </div>
      ) : heatmap ? (
        <HeatmapCalendar entries={heatmap.entries} />
      ) : (
        <div className="skeleton h-16" />
      )}
    </section>
  );
}
