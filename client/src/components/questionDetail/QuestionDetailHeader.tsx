import { ArrowLeft } from "lucide-react";
import { StarRating } from "../StarRating";

// 문제 메타: 문제를 못 받은 사유 화면이면 없음 (뒤로가기만)
interface QuestionMeta {
  readonly topicName: string;
  readonly difficulty: number;
}

type QuestionDetailHeaderProps = (QuestionMeta | { readonly topicName?: undefined; readonly difficulty?: undefined }) & {
  readonly onBack: () => void;
};

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
      {difficulty !== undefined && (
        <div className="flex items-center gap-2">
          <span className="badge-topic">{topicName}</span>
          <StarRating level={difficulty} />
        </div>
      )}
    </header>
  );
}
