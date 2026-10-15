import type { CorrectRateTone } from "./correctRateTone";

/** recharts SVG 속성용 색: tokens.css 변수 참조 (hex 사본 금지, #462) */
export const CHART_COLOR = {
  brand: "var(--color-brand)",
  grid: "var(--color-border)",
  axisLabel: "var(--color-text-secondary)",
  axisTick: "var(--color-text-caption)",
} as const;

/** 정답률 구간 > 차트 막대 색 */
export const CHART_COLOR_BY_TONE: Readonly<Record<CorrectRateTone, string>> = {
  success: "var(--color-semantic-success)",
  brand: "var(--color-brand)",
  warning: "var(--color-semantic-warning)",
  error: "var(--color-semantic-error)",
};
