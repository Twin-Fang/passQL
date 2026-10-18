import { Link } from "react-router-dom";
import { ChevronRight, Heart, Lock, MessageSquare } from "lucide-react";
import { toCommunityQuestionPath } from "../../lib/communityPresentation";
import { formatNotificationTime } from "../../lib/notificationPresentation";
import type { CommunityFeedCard } from "../../types/api";

interface CommunityFeedCardItemProps {
  readonly card: CommunityFeedCard;
}

/** 피드 문제 카드: 지문 일부 + 토픽 + 의견 수 + 최근 활동, 풀지 않은 문제는 잠금 표시 */
export default function CommunityFeedCardItem({ card }: CommunityFeedCardItemProps) {
  return (
    <li>
      <Link
        to={toCommunityQuestionPath(card.questionUuid)}
        className="flex items-start gap-3 px-4 py-3.5 hover:bg-surface transition-colors"
      >
        <div className="flex-1 min-w-0 space-y-1.5">
          {card.topicName && <span className="badge-topic">{card.topicName}</span>}
          <p className="text-sm text-text-primary line-clamp-2 break-words">{card.stemPreview}</p>
          <div className="flex items-center flex-wrap gap-x-3 gap-y-1 text-xs text-text-caption">
            <span className="inline-flex items-center gap-1">
              <MessageSquare size={12} aria-hidden="true" />
              의견 {card.postCount}
            </span>
            {card.myPostCount !== null && <span>내 의견 {card.myPostCount}</span>}
            {card.receivedLikeCount !== null && (
              <span className="inline-flex items-center gap-1">
                <Heart size={12} aria-hidden="true" />
                {card.receivedLikeCount}
              </span>
            )}
            <span>{formatNotificationTime(card.lastActivityAt)}</span>
          </div>
        </div>
        {!card.isSolvedByMe && (
          <span className="shrink-0 inline-flex items-center gap-1 text-xs text-text-caption mt-0.5">
            <Lock size={12} aria-hidden="true" />
            풀면 열려요
          </span>
        )}
        <ChevronRight size={16} className="shrink-0 text-text-caption mt-0.5" aria-hidden="true" />
      </Link>
    </li>
  );
}
