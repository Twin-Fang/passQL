import { useLayoutEffect, useState } from "react";

// 문서 루트 CSS 변수: 풀이 화면 하단 고정 바(제출 바·피드백 바) 중 가장 높은 값 (px)
export const PRACTICE_BOTTOM_BAR_HEIGHT_VARIABLE = "--practice-bottom-bar-height";

// 떠 있는 바별 높이 (피드백 바가 제출 바를 덮는 동안 둘 다 등록됨 > 큰 값 사용)
const barHeightByBarId = new Map<symbol, number>();

/** 등록된 바 높이 최댓값 > 문서 루트 CSS 변수 */
function publishTallestBarHeight(): void {
  const tallestHeight = Math.max(0, ...barHeightByBarId.values());
  document.documentElement.style.setProperty(PRACTICE_BOTTOM_BAR_HEIGHT_VARIABLE, `${tallestHeight}px`);
}

/**
 * 하단 고정 바 높이 측정 > CSS 변수 공개 (해설 하단 시트가 바 바로 위에 붙어 버튼을 가리지 않게, #521)
 * 바가 사라지면 등록 해제 후 다시 계산. 반환값을 바 요소의 ref 로 (늦게 그려지는 바도 측정)
 */
export function usePracticeBottomBarHeight(): (barElement: HTMLElement | null) => void {
  const [barElement, setBarElement] = useState<HTMLElement | null>(null);
  useLayoutEffect(() => {
    if (!barElement) return;
    const barId = Symbol("practiceBottomBar");
    const measure = () => {
      barHeightByBarId.set(barId, barElement.getBoundingClientRect().height);
      publishTallestBarHeight();
    };
    measure();
    // jsdom 등 ResizeObserver 없는 환경은 첫 측정값만 사용
    const resizeObserver = typeof ResizeObserver === "undefined" ? null : new ResizeObserver(measure);
    resizeObserver?.observe(barElement);
    return () => {
      resizeObserver?.disconnect();
      barHeightByBarId.delete(barId);
      publishTallestBarHeight();
    };
  }, [barElement]);
  return setBarElement;
}
