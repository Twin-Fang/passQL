// 풀이 메모 획 (#904, 앱 PassqlMemoStroke 대응): 도구·색·점 목록, 지우개 닿음 판정, 부드러운 선 경로

// 도구 3종: 펜(가는 선), 형광펜(굵은 반투명 노랑), 지우개(닿은 획 통째로)
export type SolvingMemoTool = "pen" | "highlighter" | "eraser";
// 펜 색 3종 (tokens.css --color-memo-ink-*)
export type SolvingMemoInk = "red" | "blue" | "black";

export interface SolvingMemoPoint {
  readonly x: number;
  readonly y: number;
}

// 획 하나: 메모 층 좌표 (내용과 함께 스크롤). 형광펜은 색 고정 (ink 무시)
export interface SolvingMemoStroke {
  readonly tool: Exclude<SolvingMemoTool, "eraser">;
  readonly ink: SolvingMemoInk;
  readonly points: readonly SolvingMemoPoint[];
}

// 선 굵기 (px): 펜 / 형광펜 (앱과 같은 값)
const PEN_WIDTH_PIXELS = 2.5;
const HIGHLIGHTER_WIDTH_PIXELS = 14;

/** 획 도구 > 선 굵기 */
export function toStrokeWidthPixels(stroke: SolvingMemoStroke): number {
  return stroke.tool === "highlighter" ? HIGHLIGHTER_WIDTH_PIXELS : PEN_WIDTH_PIXELS;
}

/** 점 > 선분(start-end) 최단 거리 */
function distanceToSegment(point: SolvingMemoPoint, start: SolvingMemoPoint, end: SolvingMemoPoint): number {
  const segmentX = end.x - start.x;
  const segmentY = end.y - start.y;
  const segmentLengthSquared = segmentX * segmentX + segmentY * segmentY;
  if (segmentLengthSquared === 0) return Math.hypot(point.x - start.x, point.y - start.y);
  const projection = ((point.x - start.x) * segmentX + (point.y - start.y) * segmentY) / segmentLengthSquared;
  const clampedProjection = Math.min(1, Math.max(0, projection));
  return Math.hypot(point.x - (start.x + segmentX * clampedProjection), point.y - (start.y + segmentY * clampedProjection));
}

/** 지우개 원(중심·반지름)이 선에 닿는지: 점·선분까지 거리 <= 반지름 + 선 반폭 */
export function isStrokeTouchedBy(stroke: SolvingMemoStroke, point: SolvingMemoPoint, radiusPixels: number): boolean {
  const reach = radiusPixels + toStrokeWidthPixels(stroke) / 2;
  const { points } = stroke;
  if (points.length === 1) return Math.hypot(points[0].x - point.x, points[0].y - point.y) <= reach;
  return points.some((current, index) => index > 0 && distanceToSegment(point, points[index - 1], current) <= reach);
}

/** 점 목록 > 이웃 점 중점을 잇는 2차 곡선 경로 (캔버스 현재 경로에 그림) */
export function traceSmoothPath(context: CanvasRenderingContext2D, points: readonly SolvingMemoPoint[]): void {
  context.beginPath();
  context.moveTo(points[0].x, points[0].y);
  for (let index = 1; index < points.length - 1; index++) {
    const midpointX = (points[index].x + points[index + 1].x) / 2;
    const midpointY = (points[index].y + points[index + 1].y) / 2;
    context.quadraticCurveTo(points[index].x, points[index].y, midpointX, midpointY);
  }
  const lastPoint = points[points.length - 1];
  context.lineTo(lastPoint.x, lastPoint.y);
}
