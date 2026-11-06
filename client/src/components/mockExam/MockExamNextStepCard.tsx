import { Compass } from "lucide-react";
import StatsAiAnalysisActions from "../stats/StatsAiAnalysisActions";
import type { MockExamNextStep } from "../../types/api";

interface MockExamNextStepCardProps {
  readonly nextStep: MockExamNextStep;
}

/**
 * 다음에 할 일 (프로, 서버 판정): 제목 > 한 줄 > 행동 버튼 (통계 AI 분석과 같은 행동·버튼 재사용)
 */
export default function MockExamNextStepCard({ nextStep }: MockExamNextStepCardProps) {
  return (
    <section aria-label="다음에 할 일" className="bg-surface-card border border-border rounded-2xl p-4 sm:p-5 space-y-2">
      <p className="flex items-center gap-1.5 text-xs font-semibold text-brand">
        <Compass size={14} aria-hidden="true" />
        다음에 할 일
      </p>
      <h2 className="text-base font-bold text-text-primary break-keep">{nextStep.headline}</h2>
      <p className="text-sm text-text-secondary break-keep">{nextStep.message}</p>
      <StatsAiAnalysisActions actions={nextStep.actions} />
    </section>
  );
}
