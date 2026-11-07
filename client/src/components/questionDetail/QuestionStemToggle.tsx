import { BookOpen } from "lucide-react";
import StemBlocks from "../question/StemBlocks";
import LatestTrendBadge from "../LatestTrendBadge";
import { toStemPreviewLine } from "../../lib/stemBlocks";
import type { QuestionSchemaTable } from "../../types/api";

interface QuestionStemToggleProps {
  readonly stem: string;
  readonly isStemOpen: boolean;
  readonly onToggle: () => void;
  // 최신 출제 경향 반영 문제면 라벨 옆 배지 (#523)
  readonly isLatestTrend?: boolean;
  // 스키마 표는 지문 카드 안에 같은 표 모양으로 (#903)
  readonly schemaTables?: readonly QuestionSchemaTable[] | null;
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}

/**
 * 문제 지문 토글: 펼침 > 지문 블록(스키마 표 포함), 접힘 > 한 줄 미리보기
 */
export default function QuestionStemToggle({
  stem,
  isStemOpen,
  onToggle,
  isLatestTrend = false,
  schemaTables,
  schemaDdl,
  schemaSampleData,
}: QuestionStemToggleProps) {
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
        <StemBlocks stem={stem} schemaTables={schemaTables} schemaDdl={schemaDdl} schemaSampleData={schemaSampleData} />
      ) : (
        // 접힌 상태: 표·코드 자리표시 후 한 줄 truncate
        <p className="text-body text-sm truncate">
          {toStemPreviewLine(stem)}
        </p>
      )}
    </button>
  );
}
