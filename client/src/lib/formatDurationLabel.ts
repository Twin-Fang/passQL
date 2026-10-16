/**
 * 소요 시간(ms) > 표시 문구 (45초, 2분, 2분 5초). 0 이하·비정상 값은 0초
 */
export function formatDurationLabel(durationMilliseconds: number): string {
  if (!Number.isFinite(durationMilliseconds) || durationMilliseconds <= 0) return "0초";
  const totalSeconds = Math.round(durationMilliseconds / 1000);
  if (totalSeconds < 60) return `${totalSeconds}초`;
  const minutes = Math.floor(totalSeconds / 60);
  const remainingSeconds = totalSeconds % 60;
  return remainingSeconds > 0 ? `${minutes}분 ${remainingSeconds}초` : `${minutes}분`;
}
