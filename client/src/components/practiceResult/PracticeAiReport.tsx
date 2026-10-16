import { Sparkles } from "lucide-react";
import MarkdownText from "../MarkdownText";

interface PracticeAiReportProps {
  // 로딩 null(스켈레톤), 성공 텍스트 (실패 false 는 호출부에서 숨김)
  readonly aiComment: string | null;
}

/**
 * AI 리포트: 뱃지 + 로딩 스켈레톤 또는 단어별 fade-in 코멘트
 */
export default function PracticeAiReport({ aiComment }: PracticeAiReportProps) {
  return (
    <>
      <div className="flex justify-center mb-5">
        <span className="inline-flex items-center gap-2 bg-brand-light text-brand text-base font-semibold px-5 py-2 rounded-full">
          <Sparkles size={16} />
          AI 리포트
        </span>
      </div>

      {/* AI 텍스트 — 로딩: 스켈레톤, 성공: 단어별 fade-in */}
      {aiComment === null ? (
        <div className="space-y-2 animate-pulse mb-6">
          <div className="h-4 bg-border rounded w-full" />
          <div className="h-4 bg-border rounded w-5/6" />
          <div className="h-4 bg-border rounded w-4/6" />
        </div>
      ) : (
        <MarkdownText
          text={aiComment}
          animated
          className="text-body leading-relaxed mb-6"
        />
      )}
    </>
  );
}
