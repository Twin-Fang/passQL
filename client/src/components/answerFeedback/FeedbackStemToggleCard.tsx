import { useState } from "react";
import { BookOpen, ChevronDown } from "lucide-react";
import StemBlocks from "../question/StemBlocks";
import { toStemPreviewLine } from "../../lib/stemBlocks";
import type { QuestionSchemaTable } from "../../types/api";

interface FeedbackStemToggleCardProps {
  readonly stem: string;
  readonly schemaTables?: readonly QuestionSchemaTable[];
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}

/**
 * 채점 결과 상단 문제 보기 토글: 접힘 > 지문 한 줄 미리보기, 펼침 > 지문 블록(스키마 표 포함)
 */
export default function FeedbackStemToggleCard({
  stem,
  schemaTables,
  schemaDdl,
  schemaSampleData,
}: FeedbackStemToggleCardProps) {
  const [isStemOpen, setIsStemOpen] = useState(false);

  return (
    <div
      className="stem-toggle-card feedback-card-anim-1"
      onClick={() => setIsStemOpen((v) => !v)}
    >
      <div className="stem-toggle-header">
        <BookOpen size={13} className="text-base-content/60 shrink-0" />
        <span className="text-xs font-semibold text-base-content/60">문제 보기</span>
        {/* 접혀있을 때 지문 첫 줄 미리보기 */}
        {!isStemOpen && (
          <span className="stem-toggle-preview">{toStemPreviewLine(stem)}</span>
        )}
        <ChevronDown
          size={13}
          className={`text-base-content/30 shrink-0 ml-auto transition-transform duration-200 ${isStemOpen ? "rotate-180" : ""}`}
        />
      </div>
      {isStemOpen && (
        <div className="stem-toggle-body" onClick={(e) => e.stopPropagation()}>
          <StemBlocks stem={stem} schemaTables={schemaTables} schemaDdl={schemaDdl} schemaSampleData={schemaSampleData} />
        </div>
      )}
    </div>
  );
}
