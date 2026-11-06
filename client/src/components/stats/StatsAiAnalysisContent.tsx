import type { ReactNode } from "react";
import { Award, Repeat, Target, TrendingUp } from "lucide-react";
import type { AiAnalysisFinding, AiStatsAnalysis } from "../../types/api";
import StatsAiAnalysisActions from "./StatsAiAnalysisActions";
import { StatsAiForecast, StatsAiForecastHint, StatsAiReadiness } from "./StatsAiForecast";

interface StatsAiAnalysisContentProps {
  readonly analysis: AiStatsAnalysis;
}

// 진단 종류 > 칩 문구·색 (WEAK 정답률 60% 미만, SHAKY 75% 미만, UNTRIED 5문제 미만이라 판단 이름)
const FINDING_CHIP_BY_KIND: Readonly<Record<AiAnalysisFinding["kind"], { label: string; className: string }>> = {
  WEAK: { label: "약점", className: "text-semantic-error-text bg-semantic-error-light" },
  SHAKY: { label: "불안정", className: "text-semantic-warning-text bg-semantic-warning-light" },
  UNTRIED: { label: "판단 이름", className: "text-text-secondary bg-surface-code" },
};

// 묶음 순차 등장 지연 (Tailwind 가 문자열 그대로 읽어야 해서 목록으로 둠, 8번째부터 같은 지연)
const STAGGER_DELAY_CLASSES = [
  "[--stagger-delay:0ms]",
  "[--stagger-delay:50ms]",
  "[--stagger-delay:100ms]",
  "[--stagger-delay:150ms]",
  "[--stagger-delay:200ms]",
  "[--stagger-delay:250ms]",
  "[--stagger-delay:300ms]",
  "[--stagger-delay:350ms]",
] as const;

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

/** 보조 한 줄: 아이콘 + 문구 (반복 오답·추세·강점·다음 목표) */
function StatsAiNoteLine({ icon, children }: { readonly icon: ReactNode; readonly children: ReactNode }) {
  return (
    <p className="flex items-start gap-1.5 text-sm text-text-secondary">
      {icon}
      <span>{children}</span>
    </p>
  );
}

/**
 * 통계 AI 분석 본문 (#861, #862): 헤드라인 > 데이터 부족 안내 > 예상 점수(또는 남은 문제 안내) > 진단(최대 2)
 * > 반복 오답·추세·강점·다음 목표 > 바로 풀기 버튼. 문구는 서버가 만든 그대로, 묶음마다 순서대로 등장
 */
export default function StatsAiAnalysisContent({ analysis }: StatsAiAnalysisContentProps) {
  const blocks: { readonly key: string; readonly node: ReactNode }[] = [
    { key: "headline", node: <p className="text-subheadline font-bold text-text-primary leading-snug">{analysis.headline}</p> },
  ];
  if (analysis.readiness) blocks.push({ key: "readiness", node: <StatsAiReadiness readiness={analysis.readiness} /> });
  if (analysis.forecast) {
    blocks.push({ key: "forecast", node: <StatsAiForecast forecast={analysis.forecast} /> });
  } else if (analysis.forecastHint) {
    blocks.push({ key: "forecast-hint", node: <StatsAiForecastHint hint={analysis.forecastHint} /> });
  }
  for (const finding of analysis.findings) {
    blocks.push({ key: `${finding.kind}-${finding.topicUuid}`, node: <StatsAiFindingRow finding={finding} /> });
  }
  if (analysis.repeatedWrong) {
    blocks.push({
      key: "repeated-wrong",
      node: (
        <StatsAiNoteLine icon={<Repeat size={14} className="text-brand shrink-0 mt-0.5" aria-hidden="true" />}>
          {analysis.repeatedWrong.text}
        </StatsAiNoteLine>
      ),
    });
  }
  if (analysis.trend) {
    blocks.push({
      key: "trend",
      node: (
        <StatsAiNoteLine icon={<TrendingUp size={14} className="text-brand shrink-0 mt-0.5" aria-hidden="true" />}>
          {analysis.trend}
        </StatsAiNoteLine>
      ),
    });
  }
  if (analysis.strength) {
    blocks.push({
      key: "strength",
      node: (
        <StatsAiNoteLine icon={<Award size={14} className="text-semantic-success shrink-0 mt-0.5" aria-hidden="true" />}>
          강점 · {analysis.strength.topicName}{" "}
          <span className="font-semibold text-semantic-success-text">{analysis.strength.correctRatePercent}%</span>
        </StatsAiNoteLine>
      ),
    });
  }
  if (analysis.nextGoal) {
    blocks.push({
      key: "next-goal",
      node: (
        <StatsAiNoteLine icon={<Target size={14} className="text-brand shrink-0 mt-0.5" aria-hidden="true" />}>
          {analysis.nextGoal}
        </StatsAiNoteLine>
      ),
    });
  }
  blocks.push({ key: "actions", node: <StatsAiAnalysisActions actions={analysis.actions} /> });

  return (
    <div className="space-y-3">
      {blocks.map((block, index) => (
        <div
          key={block.key}
          className={`animate-stagger ${STAGGER_DELAY_CLASSES[Math.min(index, STAGGER_DELAY_CLASSES.length - 1)]}`}
        >
          {block.node}
        </div>
      ))}
    </div>
  );
}
