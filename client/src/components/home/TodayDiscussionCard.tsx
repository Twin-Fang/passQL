import { Link } from "react-router-dom";
import { ChevronRight, MessageSquare } from "lucide-react";
import { useTodayDiscussion } from "../../hooks/useCommunity";
import { toCommunityQuestionPath } from "../../lib/communityPresentation";

interface TodayDiscussionCardProps {
  readonly className?: string;
}

/** 홈 '오늘의 토론' 카드 (#525): HOT 1위 한 건, 없거나 실패·로딩 중이면 숨김 */
export default function TodayDiscussionCard({ className = "" }: TodayDiscussionCardProps) {
  const { data: discussion } = useTodayDiscussion();
  if (!discussion) return null;

  return (
    <Link to={toCommunityQuestionPath(discussion.questionUuid)} className={`block mb-4 ${className}`}>
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-5 flex items-center gap-3 hover:-translate-y-0.5 hover:border-brand transition-all duration-200">
        <div className="w-10 h-10 rounded-xl bg-brand-light flex items-center justify-center shrink-0">
          <MessageSquare size={20} className="text-brand" aria-hidden="true" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold text-text-primary">오늘의 토론</p>
          <p className="text-xs text-text-secondary mt-1 line-clamp-1">{discussion.stemPreview}</p>
        </div>
        <ChevronRight size={16} className="text-text-caption shrink-0" aria-hidden="true" />
      </div>
    </Link>
  );
}
