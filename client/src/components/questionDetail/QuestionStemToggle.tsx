import { BookOpen } from "lucide-react";
import MarkdownText from "../MarkdownText";
import LatestTrendBadge from "../LatestTrendBadge";

interface QuestionStemToggleProps {
  readonly stem: string;
  readonly isStemOpen: boolean;
  readonly onToggle: () => void;
  // 최신 출제 경향 반영 문제면 라벨 옆 배지 (#523)
  readonly isLatestTrend?: boolean;
}

/** 접힌 상태용 미리보기 — 마크다운 문법 제거 후 한 줄로 */
function toStemPreviewLine(stem: string): string {
  return stem
    .replace(/```[\s\S]*?```/g, "[SQL]")
    .replace(/\n/g, " ")
    .trim();
}

/**
 * 문제 지문 토글: 펼침 > 마크다운 전체, 접힘 > 한 줄 미리보기
 */
export default function QuestionStemToggle({ stem, isStemOpen, onToggle, isLatestTrend = false }: QuestionStemToggleProps) {
  return (
    <button
      type="button"
      className="bg-brand-light border border-brand-medium rounded-2xl p-4 sm:p-6 shadow-sm w-full text-left mt-2"
      onClick={onToggle}
    >
      {/* 접힘/펼침 무관하게 항상 표시되는 지문 라벨 */}
      <div className="flex items-center gap-1.5 mb-2 text-brand text-xs font-semibold uppercase tracking-wide">
        <BookOpen size={12} className="shrink-0" />
        문제
        {isLatestTrend && <span className="ml-1 normal-case tracking-normal"><LatestTrendBadge /></span>}
      </div>
      {isStemOpen ? (
        // 펼친 상태: MarkdownText로 코드 블록 포함 마크다운 렌더링
        <MarkdownText
          text={stem}
          className="text-sm text-body min-w-0 w-full"
        />
      ) : (
        // 접힌 상태: 마크다운 문법 제거 후 한 줄 truncate
        <p className="text-body text-sm truncate">
          {toStemPreviewLine(stem)}
        </p>
      )}
    </button>
  );
}
