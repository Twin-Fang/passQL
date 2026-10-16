import { getReadinessCopy } from "../../constants/readinessCopy";
import ProgressBar from "../ProgressBar";
import HomeRetryButton from "./HomeRetryButton";
import type { ProgressResponse } from "../../types/api";

interface ReadinessSectionProps {
  readonly progress: ProgressResponse | undefined;
  readonly isLoading: boolean;
  readonly isError: boolean;
  readonly onRetry: () => void;
  readonly staggerClassName: string;
}

/**
 * 홈 합격 준비도 / 통계: 로딩 / 실패 재시도 / 준비도 카드(readiness 있음) / 푼 문제·정답률 카드
 */
export default function ReadinessSection({ progress, isLoading, isError, onRetry, staggerClassName }: ReadinessSectionProps) {
  if (isLoading) {
    return (
      <section className={`grid grid-cols-2 gap-3 mb-4 ${staggerClassName}`}>
        <div className="skeleton h-24" />
        <div className="skeleton h-24" />
      </section>
    );
  }
  if (isError) {
    return (
      /* progress 에러 — 로딩 skeleton과 동일한 2칸 그리드 자리에 배치해 레이아웃 안정 */
      <section className={`bg-surface-card border border-border rounded-2xl p-4 sm:p-6 mb-4 ${staggerClassName}`}>
        <p className="text-sm text-text-secondary mb-3">합격 준비도</p>
        <div className="flex flex-col items-center gap-2 py-2 text-center">
          <p className="text-sm text-text-caption">학습 데이터를 불러올 수 없습니다</p>
          <HomeRetryButton onRetry={onRetry} />
        </div>
      </section>
    );
  }
  if (progress?.readiness) {
    return (
      // readiness 데이터가 있으면 합격 준비도 카드
      <section className={`bg-surface-card border border-border rounded-2xl p-4 sm:p-6 mb-4 ${staggerClassName}`}>
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-sm text-text-secondary">합격 준비도</h2>
          <span className="text-h1 text-brand">
            {Math.round(progress.readiness.score * 100)}%
          </span>
        </div>
        <ProgressBar
          fillPercent={progress.readiness.score * 100}
          trackClassName="h-2 bg-border mb-3"
          fillClassName="bg-brand transition-all"
        />
        <p className="text-sm text-text-secondary">
          {getReadinessCopy(
            progress.readiness.toneKey,
            progress.readiness.score,
          )}
        </p>
        <div className="flex gap-4 mt-3 text-xs text-text-caption">
          <span>맞힌 비율 {Math.round(progress.readiness.accuracy * 100)}%</span>
          <span>
            공부 범위 {Math.round(progress.readiness.coverage * 100)}%
          </span>
          <span>꾸준함 {Math.round(progress.readiness.recency * 100)}%</span>
        </div>
      </section>
    );
  }

  // progress 에러/미로드 시 0으로 안전하게 fallback
  const solvedCount = progress?.solvedCount ?? 0;
  const correctRate = progress?.correctRate ?? 0;
  return (
    // readiness 없으면 간략 통계 카드
    <section className={`grid grid-cols-2 gap-3 mb-4 ${staggerClassName}`}>
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 flex flex-col items-start">
        <span className="text-h1 text-brand">{solvedCount}</span>
        <span className="text-sm text-text-secondary mt-1">푼 문제</span>
      </div>
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 flex flex-col items-start">
        <span className="text-h1 text-brand">
          {Math.round(correctRate * 100)}%
        </span>
        <span className="text-sm text-text-secondary mt-1">정답률</span>
        <ProgressBar
          fillPercent={correctRate * 100}
          trackClassName="mt-2 h-1 bg-border"
          fillClassName="bg-brand"
        />
      </div>
    </section>
  );
}
