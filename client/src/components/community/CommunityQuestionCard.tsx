import { Link } from "react-router-dom";
import { RotateCcw } from "lucide-react";
import { useQuestionDetail } from "../../hooks/useQuestionDetail";

interface CommunityQuestionCardProps {
  readonly questionUuid: string;
}

/** 지문 마크다운(코드 펜스·표 구분선) > 한 줄 미리보기 텍스트 */
function toPlainStemPreview(stem: string): string {
  return stem.replace(/```\w*/g, " ").replace(/[|`#*]/g, " ").replace(/\s+/g, " ").trim();
}

/** 의견 화면 상단 문제 카드: 토픽 배지 + 지문 앞 3줄 + 문제 다시 보기 (조회 실패·로딩 중이면 링크만) */
export default function CommunityQuestionCard({ questionUuid }: CommunityQuestionCardProps) {
  const { data: question } = useQuestionDetail(questionUuid);

  return (
    <section className="bg-surface-card border border-border rounded-2xl p-4 space-y-2" aria-label="문제">
      {question?.topicName && <span className="badge-topic">{question.topicName}</span>}
      {question ? (
        <p className="text-sm text-text-primary line-clamp-3 break-words">{toPlainStemPreview(question.stem)}</p>
      ) : (
        <div className="space-y-2" aria-hidden="true">
          <div className="h-3.5 w-full rounded bg-surface" />
          <div className="h-3.5 w-2/3 rounded bg-surface" />
        </div>
      )}
      <Link to={`/questions/${questionUuid}`} className="inline-flex items-center gap-1 text-xs font-semibold text-brand">
        <RotateCcw size={12} aria-hidden="true" />
        문제 다시 보기
      </Link>
    </section>
  );
}
