import { useState } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";
import MockExamReviewDetail from "./MockExamReviewDetail";
import type { MockExamQuestionReview } from "../../types/api";

interface MockExamReviewListProps {
  readonly reviews: readonly MockExamQuestionReview[];
  // 정오표에서 고른 문항 (펼치고 그 행으로 스크롤)
  readonly openQuestionNumber: number | null;
  readonly onToggleQuestion: (questionNumber: number) => void;
}

/** 문항 행 id (정오표 > 행 스크롤 대상) */
export function toReviewRowElementId(questionNumber: number): string {
  return `mock-exam-review-${questionNumber}`;
}

/**
 * 문항별 해설 목록 (프로): 오답만 보기 토글 > 행(번호·토픽·정오) > 펼침(해설)
 */
export default function MockExamReviewList({ reviews, openQuestionNumber, onToggleQuestion }: MockExamReviewListProps) {
  const [isWrongOnly, setIsWrongOnly] = useState(false);
  // 오답만 보기여도 정오표에서 고른 문항은 남김
  const visibleReviews = isWrongOnly
    ? reviews.filter((review) => !review.isCorrect || review.questionNumber === openQuestionNumber)
    : reviews;

  return (
    <section aria-label="문항별 해설">
      <div className="flex items-center justify-between mb-2 px-1">
        <h2 className="text-sm text-text-secondary">문항별 해설</h2>
        <label className="flex items-center gap-2 text-sm text-text-secondary cursor-pointer">
          <input
            type="checkbox"
            className="toggle toggle-sm toggle-primary"
            checked={isWrongOnly}
            onChange={(event) => setIsWrongOnly(event.target.checked)}
          />
          오답만 보기
        </label>
      </div>
      <ul className="bg-surface-card border border-border rounded-2xl divide-y divide-border">
        {visibleReviews.map((review) => {
          const isOpen = openQuestionNumber === review.questionNumber;
          const detailElementId = `${toReviewRowElementId(review.questionNumber)}-detail`;
          return (
            <li key={review.questionNumber} id={toReviewRowElementId(review.questionNumber)} className="scroll-mt-4">
              <button
                type="button"
                aria-expanded={isOpen}
                aria-controls={detailElementId}
                className="w-full flex items-center gap-3 p-4 text-left focus-visible:outline-2 focus-visible:outline-offset-[-2px] focus-visible:outline-brand"
                onClick={() => onToggleQuestion(review.questionNumber)}
              >
                <span className="w-8 text-sm font-bold tabular-nums text-text-primary">{review.questionNumber}</span>
                <span className="flex-1 min-w-0 text-sm text-text-secondary truncate">{review.topicName ?? ""}</span>
                <span
                  className={`badge badge-sm border-0 ${
                    review.isCorrect
                      ? "bg-semantic-success-light text-semantic-success-text"
                      : "bg-semantic-error-light text-semantic-error-text"
                  }`}
                >
                  {review.isCorrect ? "정답" : review.selectedChoiceKey === null ? "안 품" : "오답"}
                </span>
                {isOpen ? (
                  <ChevronUp size={16} className="text-text-caption shrink-0" aria-hidden="true" />
                ) : (
                  <ChevronDown size={16} className="text-text-caption shrink-0" aria-hidden="true" />
                )}
              </button>
              {isOpen && (
                <div id={detailElementId} className="px-4 pb-4">
                  <MockExamReviewDetail review={review} />
                </div>
              )}
            </li>
          );
        })}
      </ul>
    </section>
  );
}
