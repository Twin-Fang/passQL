import type { ReactNode } from "react";
import { Target, Clock, Timer } from "lucide-react";
import ScoreCountUp from "../ScoreCountUp";
import { formatDurationLabel } from "../../lib/formatDurationLabel";

interface PracticeScoreSummaryProps {
  readonly topicName: string | null;
  readonly correctCount: number;
  readonly totalCount: number;
  readonly totalDurationMilliseconds: number;
  // 통계 3칸(정답률, 총 시간, 문제당 평균) 등장 여부
  readonly visibleStats: readonly boolean[];
  readonly onScoreCountComplete: () => void;
}

interface PracticeStatItemProps {
  readonly isVisible: boolean;
  readonly value: ReactNode;
  readonly label: ReactNode;
}

/** 통계 1칸: 값 + 아이콘 라벨, 등장 시 아래에서 페이드인 */
function PracticeStatItem({ isVisible, value, label }: PracticeStatItemProps) {
  return (
    <div
      className={`text-center transition-all duration-300 ease-out ${isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-3"}`}
    >
      <div className="text-lg font-bold">{value}</div>
      <div className="flex items-center gap-1 text-xs text-text-caption mt-0.5 justify-center">
        {label}
      </div>
    </div>
  );
}

/**
 * 연습 결과 1단계: 토픽 뱃지 > 점수 카운트업 > 정답률·총 시간·문제당 평균
 */
export default function PracticeScoreSummary({
  topicName,
  correctCount,
  totalCount,
  totalDurationMilliseconds,
  visibleStats,
  onScoreCountComplete,
}: PracticeScoreSummaryProps) {
  const totalDuration = formatDurationLabel(totalDurationMilliseconds);
  const averageDuration =
    totalCount > 0
      ? formatDurationLabel(
          Math.round(totalDurationMilliseconds / totalCount),
        )
      : "0초";

  return (
    <>
      <span className="inline-block bg-brand-light text-brand text-sm font-medium px-3.5 py-1 rounded-full mb-8">
        {topicName}
      </span>
      <ScoreCountUp
        target={correctCount}
        total={totalCount}
        onComplete={onScoreCountComplete}
      />
      <div className="flex gap-8 mt-8">
        <PracticeStatItem
          isVisible={visibleStats[0]}
          value={
            <>
              {totalCount > 0
                ? Math.round((correctCount / totalCount) * 100)
                : 0}
              %
            </>
          }
          label={
            <>
              <Target size={11} className="text-text-caption" />
              정답률
            </>
          }
        />
        <PracticeStatItem
          isVisible={visibleStats[1]}
          value={totalDuration}
          label={
            <>
              <Clock size={11} className="text-text-caption" />총 시간
            </>
          }
        />
        <PracticeStatItem
          isVisible={visibleStats[2]}
          value={averageDuration}
          label={
            <>
              <Timer size={11} className="text-text-caption" />
              문제당 평균
            </>
          }
        />
      </div>
    </>
  );
}
