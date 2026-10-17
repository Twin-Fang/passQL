import { useState, useRef, useMemo } from "react";
import type { HeatmapEntry } from "../types/api";
import { useCssVariables } from "../hooks/useCssVariables";

// 히트맵 단계(0~4) > 칸 배경 클래스 (색 값은 tokens.css --color-heat-*)
const HEAT_LEVEL_BACKGROUND_CLASSES = [
  "bg-heat-0",
  "bg-heat-1",
  "bg-heat-2",
  "bg-heat-3",
  "bg-heat-4",
] as const;
// 진한 칸(3단계 이상)은 흰 글자
const DARK_HEAT_LEVEL_MINIMUM = 3;
// 툴팁과 셀 사이 간격 (px)
const TOOLTIP_GAP_PIXELS = 8;

export function getLevel(count: number): number {
  if (count === 0) return 0;
  if (count === 1) return 1;
  if (count <= 3) return 2;
  if (count <= 5) return 3;
  return 4;
}

export function buildDayMap(entries: readonly HeatmapEntry[]): Map<string, HeatmapEntry> {
  const map = new Map<string, HeatmapEntry>();
  for (const e of entries) {
    map.set(e.date, e);
  }
  return map;
}

export function getLast30Days(): readonly string[] {
  const days: string[] = [];
  const today = new Date();
  for (let i = 29; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    // 로컬 타임존 기준으로 YYYY-MM-DD 생성 (toISOString은 UTC 기준이라 한국에서 날짜 밀림 발생)
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    days.push(`${year}-${month}-${day}`);
  }
  return days;
}

/** 날짜 문자열(YYYY-MM-DD)을 "4월 12일" 형식으로 변환 — 문자열 슬라이싱으로 타임존 문제 회피 */
function formatDateKo(dateStr: string): string {
  const month = Number(dateStr.slice(5, 7));
  const day = Number(dateStr.slice(8, 10));
  return `${month}월 ${day}일`;
}

interface TooltipState {
  date: string;
  solvedCount: number;
  correctCount: number;
  /** 툴팁을 띄울 셀의 DOM rect (위치 계산용) */
  cellRect: DOMRect;
}

interface HeatmapCalendarProps {
  readonly entries: readonly HeatmapEntry[];
}

export function HeatmapCalendar({ entries }: HeatmapCalendarProps) {
  // entries가 바뀔 때만 Map 재생성
  const dayMap = useMemo(() => buildDayMap(entries), [entries]);
  // 마운트 시 한 번만 계산
  const days = useMemo(() => getLast30Days(), []);

  const [tooltip, setTooltip] = useState<TooltipState | null>(null);
  // 모바일 long press 타이머
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  // 컨테이너 ref — 툴팁 위치를 컨테이너 기준으로 계산
  const containerRef = useRef<HTMLDivElement>(null);
  // 툴팁 요소 — 위치 CSS 변수 주입 대상
  const tooltipRef = useRef<HTMLDivElement>(null);

  // 툴팁 위치: 셀 중앙 위 (컨테이너 기준)
  const tooltipPosition = useMemo(() => {
    if (!tooltip || !containerRef.current) return { leftPixels: 0, topPixels: 0 };
    const containerRect = containerRef.current.getBoundingClientRect();
    return {
      leftPixels: tooltip.cellRect.left - containerRect.left + tooltip.cellRect.width / 2,
      topPixels: tooltip.cellRect.top - containerRect.top - TOOLTIP_GAP_PIXELS,
    };
  }, [tooltip]);
  useCssVariables(tooltipRef, {
    "--tooltip-left": `${tooltipPosition.leftPixels}px`,
    "--tooltip-top": `${tooltipPosition.topPixels}px`,
  });

  const hideTooltip = () => setTooltip(null);

  return (
    // position: relative — 툴팁 absolute 기준점
    <div ref={containerRef} className="relative">
      <div className="flex flex-wrap gap-1">
        {days.map((date) => {
          const entry = dayMap.get(date) ?? { date, solvedCount: 0, correctCount: 0 };
          const level = getLevel(entry.solvedCount);
          // 타임존 문제 회피: 문자열에서 직접 일(day) 추출
          const dayLabel = Number(date.slice(8, 10));
          return (
            <div
              key={date}
              className={`w-6 h-6 rounded flex items-center justify-center text-micro cursor-default select-none ${HEAT_LEVEL_BACKGROUND_CLASSES[level]} ${
                level >= DARK_HEAT_LEVEL_MINIMUM ? "text-on-brand" : "text-text-caption"
              }`}
              onMouseEnter={(e) => setTooltip({
                date: entry.date,
                solvedCount: entry.solvedCount,
                correctCount: entry.correctCount,
                cellRect: e.currentTarget.getBoundingClientRect(),
              })}
              onMouseLeave={hideTooltip}
              onTouchStart={(e) => {
                const target = e.currentTarget;
                // 500ms 이상 누르면 long press로 판정
                longPressTimer.current = setTimeout(() => {
                  setTooltip({
                    date: entry.date,
                    solvedCount: entry.solvedCount,
                    correctCount: entry.correctCount,
                    cellRect: target.getBoundingClientRect(),
                  });
                }, 500);
              }}
              onTouchEnd={() => {
                if (longPressTimer.current) {
                  clearTimeout(longPressTimer.current);
                  longPressTimer.current = null;
                }
              }}
              onTouchMove={() => {
                // 스크롤 시 long press 취소
                if (longPressTimer.current) {
                  clearTimeout(longPressTimer.current);
                  longPressTimer.current = null;
                }
              }}
            >
              {dayLabel}
            </div>
          );
        })}
      </div>

      {/* 히트맵 범례 */}
      <div className="flex items-center gap-1 mt-2 justify-end">
        <span className="text-micro text-text-caption">0</span>
        {HEAT_LEVEL_BACKGROUND_CLASSES.map((backgroundClass) => (
          <div key={backgroundClass} className={`w-3 h-3 rounded-sm ${backgroundClass}`} />
        ))}
        <span className="text-micro text-text-caption">6+</span>
      </div>

      {/* 툴팁 — hover/long press 시 셀 위에 표시 */}
      {tooltip && (
        <div
          ref={tooltipRef}
          className="absolute z-50 pointer-events-none whitespace-nowrap rounded-lg px-3 py-2 text-xs text-text-inverse bg-surface-inverse shadow-lg [left:var(--tooltip-left)] [top:var(--tooltip-top)] -translate-x-1/2 -translate-y-full"
        >
          <div className="font-medium">{formatDateKo(tooltip.date)}</div>
          <div className="mt-0.5 text-text-inverse-secondary">
            {tooltip.solvedCount > 0
              ? `${tooltip.solvedCount}문제 · 정답률 ${Math.round((tooltip.correctCount / tooltip.solvedCount) * 100)}%`
              : "풀이 없음"}
          </div>
          {/* 툴팁 하단 꼬리 삼각형 */}
          <div className="absolute left-1/2 -translate-x-1/2 bottom-0 translate-y-full w-0 h-0 border-x-[5px] border-x-transparent border-t-[5px] border-t-surface-inverse" />
        </div>
      )}
    </div>
  );
}
