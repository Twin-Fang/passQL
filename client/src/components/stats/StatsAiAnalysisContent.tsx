import { Award, TrendingUp } from "lucide-react";
import type { AiAnalysisFinding, AiStatsAnalysis } from "../../types/api";
import StatsAiAnalysisActions from "./StatsAiAnalysisActions";

interface StatsAiAnalysisContentProps {
  readonly analysis: AiStatsAnalysis;
}

// 진단 종류 > 칩 문구·색 (WEAK 정답률 60% 미만, SHAKY 75% 미만, UNTRIED 5문제 미만이라 판단 이름)
const FINDING_CHIP_BY_KIND: Readonly<Record<AiAnalysisFinding["kind"], { label: string; className: string }>> = {
  WEAK: { label: "약점", className: "text-semantic-error-text bg-semantic-error-light" },
  SHAKY: { label: "불안정", className: "text-semantic-warning-text bg-semantic-warning-light" },
  UNTRIED: { label: "판단 이름", className: "text-text-secondary bg-surface-code" },
};

/** 진단 1건: 종류 칩 + 토픽 이름 > 근거 수치 > 해석(있을 때) */
function StatsAiFindingRow({ finding }: { readonly finding: AiAnalysisFinding }) {
  const chip = FINDING_CHIP_BY_KIND[finding.kind];
  return (
    <div className="bg-surface rounded-xl p-3">
      <div className="flex items-center gap-2">
        <span className={`text-caption2 font-semibold px-1.5 py-px rounded-full shrink-0 ${chip.className}`}>
          {chip.label}
        </span>
        <span className="text-footnote font-semibold text-text-primary truncate">{finding.topicName}</span>
      </div>
      <p className="text-caption1 text-text-caption mt-1">{finding.evidence}</p>
      {finding.insight && <p className="text-sm text-text-secondary leading-relaxed mt-1.5">{finding.insight}</p>}
    </div>
  );
}

/**
 * 통계 AI 분석 본문 (#861): 헤드라인 > 진단(최대 2) > 추세 > 강점 > 바로 풀기 버튼
 * 문구(headline·evidence·label)는 서버가 만든 그대로 표시
 */
export default function StatsAiAnalysisContent({ analysis }: StatsAiAnalysisContentProps) {
  return (
    <div className="space-y-3">
      <p className="text-subheadline font-bold text-text-primary leading-snug">{analysis.headline}</p>

      {analysis.findings.length > 0 && (
        <div className="space-y-2">
          {analysis.findings.map((finding) => (
            <StatsAiFindingRow key={`${finding.kind}-${finding.topicUuid}`} finding={finding} />
          ))}
        </div>
      )}

      {analysis.trend && (
        <p className="flex items-start gap-1.5 text-sm text-text-secondary">
          <TrendingUp size={14} className="text-brand shrink-0 mt-0.5" aria-hidden="true" />
          <span>{analysis.trend}</span>
        </p>
      )}

      {analysis.strength && (
        <p className="flex items-center gap-1.5 text-sm text-text-secondary">
          <Award size={14} className="text-semantic-success shrink-0" aria-hidden="true" />
          <span>
            강점 · {analysis.strength.topicName}{" "}
            <span className="font-semibold text-semantic-success-text">{analysis.strength.correctRatePercent}%</span>
          </span>
        </p>
      )}

      <StatsAiAnalysisActions actions={analysis.actions} />
    </div>
  );
}
