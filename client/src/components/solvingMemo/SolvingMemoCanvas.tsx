import { useCallback, useLayoutEffect, useRef, useState, type PointerEvent } from "react";
import type { SolvingMemo } from "../../hooks/useSolvingMemo";
import {
  toStrokeWidthPixels,
  traceSmoothPath,
  type SolvingMemoPoint,
  type SolvingMemoStroke,
} from "../../lib/solvingMemoStroke";

// 지우개 원 반지름 (손가락 끝 크기, px)
const ERASER_RADIUS_PIXELS = 12;
// 이보다 가까운 다음 점은 버림 (획 점 수 줄임, px)
const MINIMUM_POINT_GAP_PIXELS = 1.5;
// 형광펜 불투명도 (아래 글자가 비치게, 앱과 같은 값)
const HIGHLIGHTER_OPACITY = 0.45;

interface SolvingMemoCanvasProps {
  readonly memo: SolvingMemo;
  // 메모를 나눠 담는 문항 식별자 (문제 UUID·문항 번호)
  readonly pageKey: string;
}

interface CanvasSize {
  readonly widthPixels: number;
  readonly heightPixels: number;
}

/** 획 색: 형광펜은 노랑 고정, 펜은 고른 색 (tokens.css 값을 읽음) */
function toStrokeColor(canvas: HTMLCanvasElement, stroke: SolvingMemoStroke): string {
  const tokenName = stroke.tool === "highlighter" ? "--color-memo-highlighter" : `--color-memo-ink-${stroke.ink}`;
  return getComputedStyle(canvas).getPropertyValue(tokenName).trim();
}

/** 획 하나 그리기: 점 1개면 콕 찍은 원, 아니면 부드러운 선 */
function paintStroke(context: CanvasRenderingContext2D, canvas: HTMLCanvasElement, stroke: SolvingMemoStroke): void {
  const color = toStrokeColor(canvas, stroke);
  const widthPixels = toStrokeWidthPixels(stroke);
  context.globalAlpha = stroke.tool === "highlighter" ? HIGHLIGHTER_OPACITY : 1;
  if (stroke.points.length === 1) {
    context.fillStyle = color;
    context.beginPath();
    context.arc(stroke.points[0].x, stroke.points[0].y, widthPixels / 2, 0, Math.PI * 2);
    context.fill();
    return;
  }
  context.strokeStyle = color;
  context.lineWidth = widthPixels;
  context.lineCap = "round";
  context.lineJoin = "round";
  traceSmoothPath(context, stroke.points);
  context.stroke();
}

/** 가장 가까운 세로 스크롤 영역 (두 손가락 스크롤 대상) */
function findScrollContainer(element: HTMLElement): HTMLElement | null {
  for (let current = element.parentElement; current; current = current.parentElement) {
    const { overflowY } = getComputedStyle(current);
    if (overflowY === "auto" || overflowY === "scroll") return current;
  }
  return document.scrollingElement instanceof HTMLElement ? document.scrollingElement : null;
}

/** 손가락들 가운데 점 */
function centerOf(positions: Iterable<SolvingMemoPoint>): SolvingMemoPoint {
  const positionList = [...positions];
  const sum = positionList.reduce((total, position) => ({ x: total.x + position.x, y: total.y + position.y }), { x: 0, y: 0 });
  return { x: sum.x / positionList.length, y: sum.y / positionList.length };
}

/**
 * 메모 층: 문항 내용 위 캔버스 (부모 relative 를 채우고 내용과 함께 스크롤)
 * 켬: 마우스·펜·한 손가락 그리기·지우기(스크롤 멈춤), 두 손가락 스크롤 / 끔: 흐리게 보이기만, 터치는 전부 아래 내용으로
 */
export default function SolvingMemoCanvas({ memo, pageKey }: SolvingMemoCanvasProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [canvasSize, setCanvasSize] = useState<CanvasSize>({ widthPixels: 0, heightPixels: 0 });
  const inProgressStrokeRef = useRef<SolvingMemoStroke | null>(null);
  const clientPositionByPointerRef = useRef(new Map<number, SolvingMemoPoint>());
  // 손가락 2개 이상: 그리기 대신 내용 스크롤 (모두 뗄 때까지 유지)
  const isScrollingWithFingersRef = useRef(false);
  const eraseGestureIdRef = useRef(0);
  const strokes = memo.strokesOf(pageKey);

  // 내용 크기 변화 > 캔버스 크기 (jsdom 등 ResizeObserver 없으면 첫 측정값만)
  useLayoutEffect(() => {
    const host = canvasRef.current?.parentElement;
    if (!host) return;
    const measure = () => setCanvasSize({ widthPixels: host.clientWidth, heightPixels: host.clientHeight });
    measure();
    const resizeObserver = typeof ResizeObserver === "undefined" ? null : new ResizeObserver(measure);
    resizeObserver?.observe(host);
    return () => resizeObserver?.disconnect();
  }, []);

  /** 전체 다시 그리기: 화면 배율 맞춤(크기가 바뀔 때만 다시 잡음) > 저장된 획 > 그리는 중인 획 */
  const repaint = useCallback(() => {
    const canvas = canvasRef.current;
    const context = canvas?.getContext("2d");
    if (!canvas || !context) return;
    const pixelRatio = window.devicePixelRatio || 1;
    const backingWidth = Math.round(canvasSize.widthPixels * pixelRatio);
    const backingHeight = Math.round(canvasSize.heightPixels * pixelRatio);
    if (canvas.width !== backingWidth) canvas.width = backingWidth;
    if (canvas.height !== backingHeight) canvas.height = backingHeight;
    context.setTransform(pixelRatio, 0, 0, pixelRatio, 0, 0);
    context.clearRect(0, 0, canvasSize.widthPixels, canvasSize.heightPixels);
    const inProgressStroke = inProgressStrokeRef.current;
    for (const stroke of inProgressStroke ? [...strokes, inProgressStroke] : strokes) {
      paintStroke(context, canvas, stroke);
    }
  }, [strokes, canvasSize]);

  // 획·크기가 바뀌면 다시 그림 (그리는 중에는 이벤트마다 직접 호출)
  useLayoutEffect(repaint, [repaint]);

  const toLocalPoint = (event: PointerEvent<HTMLCanvasElement>): SolvingMemoPoint => {
    const rect = event.currentTarget.getBoundingClientRect();
    return { x: event.clientX - rect.left, y: event.clientY - rect.top };
  };

  const onPointerDown = (event: PointerEvent<HTMLCanvasElement>) => {
    // 마우스는 왼쪽 버튼만
    if (!memo.isMemoMode || (event.pointerType === "mouse" && event.button !== 0)) return;
    event.currentTarget.setPointerCapture(event.pointerId);
    const clientPositionByPointer = clientPositionByPointerRef.current;
    clientPositionByPointer.set(event.pointerId, { x: event.clientX, y: event.clientY });
    if (clientPositionByPointer.size > 1) {
      isScrollingWithFingersRef.current = true;
      inProgressStrokeRef.current = null;
      repaint();
      return;
    }
    const point = toLocalPoint(event);
    if (memo.selectedTool === "eraser") {
      eraseGestureIdRef.current += 1;
      memo.eraseStrokesTouchedBy(pageKey, point, ERASER_RADIUS_PIXELS, eraseGestureIdRef.current);
      return;
    }
    inProgressStrokeRef.current = { tool: memo.selectedTool, ink: memo.selectedInk, points: [point] };
    repaint();
  };

  const onPointerMove = (event: PointerEvent<HTMLCanvasElement>) => {
    const clientPositionByPointer = clientPositionByPointerRef.current;
    if (!clientPositionByPointer.has(event.pointerId)) return;
    // 두 손가락: 가운데 점의 세로 이동만큼 스크롤
    if (isScrollingWithFingersRef.current) {
      const previousCenter = centerOf(clientPositionByPointer.values());
      clientPositionByPointer.set(event.pointerId, { x: event.clientX, y: event.clientY });
      const scrollContainer = findScrollContainer(event.currentTarget);
      if (scrollContainer) scrollContainer.scrollTop -= centerOf(clientPositionByPointer.values()).y - previousCenter.y;
      return;
    }
    clientPositionByPointer.set(event.pointerId, { x: event.clientX, y: event.clientY });
    const point = toLocalPoint(event);
    if (memo.selectedTool === "eraser") {
      memo.eraseStrokesTouchedBy(pageKey, point, ERASER_RADIUS_PIXELS, eraseGestureIdRef.current);
      return;
    }
    const inProgressStroke = inProgressStrokeRef.current;
    if (!inProgressStroke) return;
    const lastPoint = inProgressStroke.points[inProgressStroke.points.length - 1];
    if (Math.hypot(point.x - lastPoint.x, point.y - lastPoint.y) < MINIMUM_POINT_GAP_PIXELS) return;
    inProgressStrokeRef.current = { ...inProgressStroke, points: [...inProgressStroke.points, point] };
    repaint();
  };

  // 손 뗌·취소: 스크롤 중이면 모두 뗄 때 종료, 그리던 획은 저장 (취소도 그린 데까지 저장)
  const onPointerEnd = (event: PointerEvent<HTMLCanvasElement>) => {
    const clientPositionByPointer = clientPositionByPointerRef.current;
    if (!clientPositionByPointer.delete(event.pointerId)) return;
    if (isScrollingWithFingersRef.current) {
      if (clientPositionByPointer.size === 0) isScrollingWithFingersRef.current = false;
      return;
    }
    const inProgressStroke = inProgressStrokeRef.current;
    inProgressStrokeRef.current = null;
    if (inProgressStroke) memo.addStroke(pageKey, inProgressStroke);
  };

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      className={`absolute inset-0 z-10 size-full transition-opacity duration-300 ${
        memo.isMemoMode ? "touch-none cursor-crosshair" : "pointer-events-none opacity-55"
      }`}
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerEnd}
      onPointerCancel={onPointerEnd}
    />
  );
}
