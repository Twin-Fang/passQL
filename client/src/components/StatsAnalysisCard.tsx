import { Sparkles } from "lucide-react";
import MarkdownText from "./MarkdownText";
import StatsAiAnalysisContent from "./stats/StatsAiAnalysisContent";
import type { AiStatsAnalysis } from "../types/api";

interface StatsAnalysisCardProps {
  readonly comment: string | null;
  // 구조화 분석 (#861), null이면 comment 텍스트로 표시
  readonly analysis?: AiStatsAnalysis | null;
  readonly isLoading?: boolean;
}

/** AI 카드 머리글: 반짝임 아이콘 + 제목 */
function StatsAiCardHeader({ title }: { readonly title: string }) {
  return (
    <div className="animate-ai-header flex items-center gap-1 mb-2">
      <div className="animate-sparkle-pop w-7 h-7 rounded-lg bg-brand-light flex items-center justify-center shrink-0">
        <Sparkles size={14} className="text-brand" />
      </div>
      <h3 className="text-base font-bold text-text-primary">{title}</h3>
    </div>
  );
}

/** 통계 AI 카드: 로딩 > 구조화 분석(있을 때) > 텍스트 코멘트 */
export default function StatsAnalysisCard({ comment, analysis, isLoading }: StatsAnalysisCardProps) {
  if (isLoading) {
    // 분석 카드 높이 근사 (헤드라인, 진단 2행, 버튼)
    return (
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 space-y-3">
        <div className="flex gap-2 items-center">
          <div className="w-7 h-7 rounded-lg bg-border animate-pulse shrink-0" />
          <div className="h-3 bg-border rounded animate-pulse w-1/4" />
        </div>
        <div className="h-4 bg-border rounded animate-pulse w-5/6" />
        <div className="h-16 bg-border rounded-xl animate-pulse" />
        <div className="h-16 bg-border rounded-xl animate-pulse" />
        <div className="h-3 bg-border rounded animate-pulse w-2/3" />
        <div className="h-11 bg-border rounded-xl animate-pulse" />
      </div>
    );
  }

  if (analysis) {
    return (
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6">
        <StatsAiCardHeader title="AI 분석" />
        <StatsAiAnalysisContent analysis={analysis} />
      </div>
    );
  }

  if (!comment) return null;

  return (
    <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6">
      <StatsAiCardHeader title="AI 한마디" />
      {/* 단어 단위 fade-in — MarkdownText animated로 Markdown 렌더링 + 순차 등장 */}
      <MarkdownText
        text={comment}
        animated
        className="text-sm text-text-secondary leading-relaxed"
      />
    </div>
  );
}
