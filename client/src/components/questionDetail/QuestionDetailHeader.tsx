import { ArrowLeft } from "lucide-react";
import { StarRating } from "../StarRating";

interface QuestionDetailHeaderProps {
  readonly topicName: string;
  readonly difficulty: number;
  readonly onBack: () => void;
}

/**
 * 단독 풀이 헤더: 뒤로가기 + 토픽 뱃지·난이도
 */
export default function QuestionDetailHeader({ topicName, difficulty, onBack }: QuestionDetailHeaderProps) {
  return (
    <header className="flex items-center justify-between h-14 px-3">
      <button
        type="button"
        className="w-8 h-8 flex items-center justify-center rounded-xl hover:bg-border transition-colors"
        onClick={onBack}
      >
        <ArrowLeft size={18} className="text-text-secondary" />
      </button>
      <div className="flex items-center gap-2">
        <span className="badge-topic">{topicName}</span>
        <StarRating level={difficulty} />
      </div>
    </header>
  );
}
