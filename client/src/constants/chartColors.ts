import type { CorrectRateTone } from "./correctRateTone";

/** recharts SVG 속성용 색: tokens.css 변수 참조 (hex 사본 금지, #462) */
export const CHART_COLOR = {
  brand: "var(--color-brand)",
  grid: "var(--color-border)",
  axisLabel: "var(--color-text-secondary)",
  axisTick: "var(--color-text-caption)",
  // 모의고사 합격선 가로줄 (#866)
  passLine: "var(--color-semantic-success)",
  // 쌓은 막대의 나머지 몫·강조하지 않은 막대 (#909, 앱 accentTint)
  brandTint: "var(--color-brand-light)",
  // 남은 오답 막대: 이번 주 강조·지난 주들 (#909)
  wrong: "var(--color-semantic-error)",
  rest: "var(--color-surface-code)",
} as const;

/** 정답률 구간 > 차트 막대 색 */
export const CHART_COLOR_BY_TONE: Readonly<Record<CorrectRateTone, string>> = {
  success: "var(--color-semantic-success)",
  brand: "var(--color-brand)",
  warning: "var(--color-semantic-warning)",
  error: "var(--color-semantic-error)",
};
