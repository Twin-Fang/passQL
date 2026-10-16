import { Link } from "react-router-dom";
import { ChevronRight } from "lucide-react";
import type { SimilarQuestion } from "../../types/api";

interface SimilarQuestionListProps {
  readonly similarQuestions: readonly SimilarQuestion[];
}

/**
 * 유사 문제 목록: 문제별 상세 링크 카드
 */
export default function SimilarQuestionList({ similarQuestions }: SimilarQuestionListProps) {
  return (
    <section className="feedback-card-anim-4">
      <p className="text-xs text-base-content/40 uppercase tracking-widest font-medium mb-2">유사 문제</p>
      <div className="space-y-2">
        {similarQuestions.map((q) => (
          <Link key={q.questionUuid} to={`/questions/${q.questionUuid}`}>
            <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 flex items-center gap-3 cursor-pointer hover:bg-surface transition-colors">
              <div className="flex-1 min-w-0">
                <p className="text-body truncate">{q.stem}</p>
                <span className="badge-topic">{q.topicName}</span>
              </div>
              <ChevronRight size={16} className="text-text-caption shrink-0" />
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
