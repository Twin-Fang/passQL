import { CheckCircle2 } from "lucide-react";
import { toExamRuleLines } from "../../lib/mockExamPresentation";
import type { MockExamRule } from "../../types/api";

interface MockExamRuleSummaryCardProps {
  readonly examRule: MockExamRule;
  // 시험 안내에서 더 보여 줄 고정 줄 (자동 제출·이어 풀기 등)
  readonly extraLines?: readonly string[];
  readonly title?: string;
}

/**
 * 시험 형식 카드: 서버 examRule > 형식·과목 구성·합격·과락 줄 (+ 안내 고정 줄)
 * 숫자는 모두 서버 값 (웹에 문항 수·시간·합격선 복사 없음)
 */
export default function MockExamRuleSummaryCard({ examRule, extraLines = [], title = "시험 형식" }: MockExamRuleSummaryCardProps) {
  const lines = [...toExamRuleLines(examRule), ...extraLines];
  return (
    <section aria-label={title} className="bg-surface-card border border-border rounded-2xl p-4 sm:p-5">
      <h2 className="text-sm font-semibold text-text-secondary mb-3">{title}</h2>
      <ul className="space-y-2">
        {lines.map((line) => (
          <li key={line} className="flex items-start gap-2 text-sm text-text-primary break-keep">
            <CheckCircle2 size={16} className="text-brand shrink-0 mt-0.5" aria-hidden="true" />
            {line}
          </li>
        ))}
      </ul>
    </section>
  );
}
