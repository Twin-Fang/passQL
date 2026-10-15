import { useEffect, useRef, useState, type ReactNode, type RefObject } from "react";
import { createPortal } from "react-dom";
import { useCssVariables } from "../hooks/useCssVariables";

// 화면 가장자리와 팝오버 사이 최소 여백 (px)
const VIEWPORT_MARGIN_PIXELS = 8;
// 버튼 아래 띄우는 간격 (px)
const ANCHOR_GAP_PIXELS = 8;
// 화살표 폭 12px 의 절반 (px)
const ARROW_HALF_WIDTH_PIXELS = 6;
// start 정렬: 팝오버 왼쪽 끝을 버튼 중앙보다 앞에 두는 거리 (px)
const START_ALIGNMENT_OFFSET_PIXELS = 24;

interface AnchoredPopoverProps {
  readonly isOpen: boolean;
  readonly anchorRef: RefObject<HTMLElement | null>;
  readonly widthPixels: number;
  // 버튼 중앙 기준: center 가운데 정렬, start 왼쪽 정렬
  readonly alignment: "center" | "start";
  readonly children: ReactNode;
}

interface PopoverPosition {
  readonly topPixels: number;
  readonly leftPixels: number;
  readonly arrowLeftPixels: number;
}

/** 버튼 아래 어두운 설명 말풍선: 위치 계산 > body 포털 렌더 (stacking context 격리 회피) */
export default function AnchoredPopover({ isOpen, anchorRef, widthPixels, alignment, children }: AnchoredPopoverProps) {
  const popoverRef = useRef<HTMLDivElement>(null);
  const [position, setPosition] = useState<PopoverPosition>({ topPixels: 0, leftPixels: 0, arrowLeftPixels: 0 });

  // 위치 계산 (fixed 기준이라 getBoundingClientRect 그대로, 화면 밖 clamp)
  useEffect(() => {
    if (!isOpen || !anchorRef.current) return;
    const anchorRect = anchorRef.current.getBoundingClientRect();
    const anchorCenterX = anchorRect.left + anchorRect.width / 2;
    const preferredLeft = alignment === "center"
      ? anchorCenterX - widthPixels / 2
      : anchorCenterX - START_ALIGNMENT_OFFSET_PIXELS;
    const maximumLeft = window.innerWidth - widthPixels - VIEWPORT_MARGIN_PIXELS;
    const leftPixels = Math.max(VIEWPORT_MARGIN_PIXELS, Math.min(preferredLeft, maximumLeft));
    setPosition({
      topPixels: anchorRect.bottom + ANCHOR_GAP_PIXELS,
      leftPixels,
      arrowLeftPixels: anchorCenterX - leftPixels - ARROW_HALF_WIDTH_PIXELS,
    });
  }, [isOpen, anchorRef, alignment, widthPixels]);

  useCssVariables(popoverRef, {
    "--popover-top": `${position.topPixels}px`,
    "--popover-left": `${position.leftPixels}px`,
    "--popover-width": `${widthPixels}px`,
    "--popover-arrow-left": `${position.arrowLeftPixels}px`,
  });

  if (!isOpen) return null;

  return createPortal(
    <div
      ref={popoverRef}
      className="animate-popover-in fixed [top:var(--popover-top)] [left:var(--popover-left)] [width:var(--popover-width)] bg-surface-inverse text-text-inverse rounded-xl p-3 z-[9999] shadow-lg"
    >
      {/* 화살표: 버튼 중앙 */}
      <div className="absolute -top-1.5 [left:var(--popover-arrow-left)] w-3 h-1.5 bg-surface-inverse [clip-path:polygon(50%_0%,0%_100%,100%_100%)]" />
      {children}
    </div>,
    document.body
  );
}
