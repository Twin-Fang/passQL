/** 정답률 구간 4개 (80%↑ 우수, 60%↑ 보통, 40%↑ 주의, 그 아래 취약) */
export type CorrectRateTone = "success" | "brand" | "warning" | "error";

/** 정답률(0~1) > 색 구간 */
export function toCorrectRateTone(correctRate: number): CorrectRateTone {
  if (correctRate >= 0.8) return "success";
  if (correctRate >= 0.6) return "brand";
  if (correctRate >= 0.4) return "warning";
  return "error";
}
