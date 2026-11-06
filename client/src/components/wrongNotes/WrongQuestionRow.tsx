import { useNavigate } from "react-router-dom";
import { XCircle } from "lucide-react";
import type { WrongQuestionItem } from "../../types/api";

// 하루 길이 (ms)
const DAY_MILLISECONDS = 1000 * 60 * 60 * 24;

/** 마지막 오답 시각 > "오늘" / "어제" / "N일 전" */
function formatLastWrongDay(isoString: string): string {
  const elapsedDays = Math.floor((Date.now() - new Date(isoString).getTime()) / DAY_MILLISECONDS);
  if (elapsedDays <= 0) return "오늘";
  if (elapsedDays === 1) return "어제";
  return `${elapsedDays}일 전`;
}

/** 오답 1건 행: 오답 표식 > 지문 미리보기 > 토픽·시점 > 다시 풀기 (문제 단독 풀이로 이동) */
export default function WrongQuestionRow({ item }: { readonly item: WrongQuestionItem }) {
  const navigate = useNavigate();

  return (
    <li className="flex items-center gap-3 px-4 py-3">
      <div className="w-9 h-9 rounded-tile bg-semantic-error-light flex items-center justify-center shrink-0">
        <XCircle size={18} className="text-semantic-error" aria-label="오답" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-semibold text-text-primary line-clamp-2 break-keep">{item.stemPreview}</p>
        <div className="flex items-center gap-1.5 mt-0.5">
          {/* 토픽 뱃지 (토픽 없는 문제는 생략) */}
          {item.topicName && (
            <span className="text-micro font-medium bg-brand-light text-brand px-1.5 py-0.5 rounded">
              {item.topicName}
            </span>
          )}
          <span className="text-caption2 text-text-caption">{formatLastWrongDay(item.lastWrongAt)}</span>
        </div>
      </div>
      <button
        type="button"
        onClick={() => navigate(`/questions/${item.questionUuid}`)}
        className="btn-compact shrink-0"
      >
        다시 풀기
      </button>
    </li>
  );
}
