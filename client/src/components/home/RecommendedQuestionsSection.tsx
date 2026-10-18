import { Link } from "react-router-dom";
import { ChevronRight, RefreshCw, Sparkles } from "lucide-react";
import { StarRating } from "../StarRating";
import type { QuestionSummary } from "../../types/api";
import LatestTrendBadge from "../LatestTrendBadge";

interface RecommendedQuestionsSectionProps {
  readonly questions: readonly QuestionSummary[] | undefined;
  readonly isLoading: boolean;
  readonly isRefreshDisabled: boolean;
  readonly isSpinning: boolean;
  // 카드 페이드인 재실행용 목록 key
  readonly refreshKey: number;
  readonly onRefresh: () => void;
  readonly onSpinEnd: () => void;
  readonly staggerClassName: string;
}

/**
 * 홈 AI 추천문제: 제목 + 새로고침 버튼 > 초기 로딩 스켈레톤 3 / 추천 문제 카드 목록
 */
export default function RecommendedQuestionsSection({
  questions,
  isLoading,
  isRefreshDisabled,
  isSpinning,
  refreshKey,
  onRefresh,
  onSpinEnd,
  staggerClassName,
}: RecommendedQuestionsSectionProps) {
  return (
    <section className={`mt-6 ${staggerClassName}`}>
      <h2 className="text-sm text-text-secondary mb-3 flex items-center gap-2">
        <Sparkles size={14} fill="currentColor" />
        AI 추천문제
        {/* 다른 추천 문제 세트를 원할 때 재요청 — staleTime 내에도 강제 refetch */}
        <button
          onClick={onRefresh}
          disabled={isRefreshDisabled}
          onAnimationEnd={onSpinEnd}
          className="p-1 rounded hover:bg-surface transition-colors disabled:opacity-40"
          aria-label="추천 문제 새로고침"
        >
          <RefreshCw
            size={13}
            className={isSpinning ? "animate-refresh-once" : ""}
          />
        </button>
      </h2>
      {isLoading ? (
        // 초기 로딩 시에만 스켈레톤 — 새로고침(isFetching)은 기존 카드 유지
        <div className="space-y-3">
          <div className="skeleton h-[72px] rounded-2xl" />
          <div className="skeleton h-[72px] rounded-2xl" />
          <div className="skeleton h-[72px] rounded-2xl" />
        </div>
      ) : (
        <div key={refreshKey} className="space-y-3">
          {questions!.map((q) => (
            <Link
              key={q.questionUuid}
              to={`/questions/${q.questionUuid}`}
              className="block animate-card-in"
            >
              <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 shadow-sm flex items-center gap-3 cursor-pointer hover:shadow-md hover:-translate-y-0.5 hover:border-brand transition-all duration-200">
                <div className="flex-1 min-w-0">
                  <p className="text-body truncate">{q.stemPreview}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="badge-topic">{q.topicName}</span>
                    {q.isLatestTrend && <LatestTrendBadge />}
                    <StarRating level={q.difficulty} />
                  </div>
                </div>
                <ChevronRight
                  size={16}
                  className="text-text-caption shrink-0"
                />
              </div>
            </Link>
          ))}
        </div>
      )}
    </section>
  );
}
