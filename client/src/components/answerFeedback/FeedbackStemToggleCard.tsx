import { useState } from "react";
import { BookOpen, ChevronDown } from "lucide-react";
import ReactMarkdown, { type Components } from "react-markdown";
import { SchemaViewer } from "../SchemaViewer";

interface FeedbackStemToggleCardProps {
  readonly stem: string;
  readonly schemaDisplay?: string | null;
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}

// stem에 마크다운 테이블/코드 포함 가능 — components prop으로 스타일 적용
const STEM_MARKDOWN_COMPONENTS: Components = {
  // 단일 \n도 시각적으로 줄바꿈 되도록 whitespace-pre-line 적용
  p({ children }) {
    return (
      <p className="text-sm text-base-content leading-relaxed mb-2 whitespace-pre-line">
        {children}
      </p>
    );
  },
  code({ children, className }) {
    const isBlock = className?.includes("language-");
    return isBlock ? (
      <pre className="bg-surface-code rounded-lg px-4 py-3 text-xs leading-relaxed whitespace-pre-wrap font-mono">
        <code>{children}</code>
      </pre>
    ) : (
      <code className="bg-surface-code px-1 rounded text-xs font-mono">
        {children}
      </code>
    );
  },
  table({ children }) {
    // 마크다운 테이블을 스크롤 가능한 컨테이너로 감쌈
    return (
      <div className="overflow-x-auto">
        <table className="w-full text-xs border-collapse">{children}</table>
      </div>
    );
  },
  th({ children }) {
    return (
      <th className="border border-border px-2 py-1 bg-surface-code text-left font-semibold text-text-secondary">
        {children}
      </th>
    );
  },
  td({ children }) {
    return (
      <td className="border border-border px-2 py-1 font-mono text-text-primary">
        {children}
      </td>
    );
  },
};

/**
 * 채점 결과 상단 문제 보기 토글: 접힘 > 지문 첫 줄 미리보기, 펼침 > 지문 마크다운 + 스키마
 */
export default function FeedbackStemToggleCard({
  stem,
  schemaDisplay,
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
          <span className="stem-toggle-preview">{stem}</span>
        )}
        <ChevronDown
          size={13}
          className={`text-base-content/30 shrink-0 ml-auto transition-transform duration-200 ${isStemOpen ? "rotate-180" : ""}`}
        />
      </div>
      {isStemOpen && (
        <div className="stem-toggle-body" onClick={(e) => e.stopPropagation()}>
          <ReactMarkdown components={STEM_MARKDOWN_COMPONENTS}>
            {stem}
          </ReactMarkdown>
          {/* 스키마가 있으면 stem 아래에 표시 — schemaDisplay 없어도 schemaDdl로 폴백 */}
          {(schemaDisplay || schemaDdl) && (
            <div className="mt-3">
              <SchemaViewer
                schemaDisplay={schemaDisplay ?? undefined}
                schemaDdl={schemaDdl ?? undefined}
                schemaSampleData={schemaSampleData ?? undefined}
              />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
