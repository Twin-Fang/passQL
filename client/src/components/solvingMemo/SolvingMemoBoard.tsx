import type { ReactNode } from "react";
import type { SolvingMemo } from "../../hooks/useSolvingMemo";
import SolvingMemoCanvas from "./SolvingMemoCanvas";
import SolvingMemoControls from "./SolvingMemoControls";

interface SolvingMemoBoardProps {
  // 풀이 화면이 들고 있는 메모 상태 (useSolvingMemo, 응시 동안 유지)
  readonly memo: SolvingMemo;
  // 지금 보이는 문항 (문제 UUID·문항 번호)
  readonly pageKey: string;
  readonly children: ReactNode;
}

/**
 * 풀이 메모 틀 (#904): 문항 내용 > 메모 층(내용과 함께 스크롤) + 켬 안내 + 펜 버튼·도구 막대
 * 끔이면 메모는 흐리게 보이기만 하고 클릭·터치·스크롤은 메모 도입 전과 같음. 화면은 문항 내용을 이것으로 감싸기만 함
 */
export default function SolvingMemoBoard({ memo, pageKey, children }: SolvingMemoBoardProps) {
  return (
    <>
      {/* pb-16: 펜 버튼이 마지막 보기를 가리지 않게 */}
      <div className="relative pb-16">
        {/* 켬 안내: 스크롤해도 위에 붙어 있음 (높이 0 이라 내용 배치 그대로) */}
        {memo.isMemoMode && (
          <div className="sticky top-2 z-20 h-0 flex items-start justify-center pointer-events-none">
            <p role="status" className="bg-surface-inverse/80 text-text-inverse text-footnote text-center rounded-full px-3 py-1.5">
              메모 중이에요. 보기를 고르려면 메모를 끄세요
            </p>
          </div>
        )}
        {children}
        <SolvingMemoCanvas memo={memo} pageKey={pageKey} />
      </div>
      <SolvingMemoControls memo={memo} pageKey={pageKey} />
    </>
  );
}
