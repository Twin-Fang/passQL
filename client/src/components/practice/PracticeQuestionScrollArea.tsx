import type { ReactNode } from "react";
import { useExplanationHistoryStore } from "../../stores/explanationHistoryStore";
import type { SolvingMemo } from "../../hooks/useSolvingMemo";
import SolvingMemoBoard from "../solvingMemo/SolvingMemoBoard";

interface PracticeQuestionScrollAreaProps {
  // 피드백바 표시 중 여부 — 측정된 바 높이만큼 하단 여백 확보
  readonly hasFeedbackBar: boolean;
  // 풀이 메모 (#904): 화면이 들고 있는 메모 상태 + 지금 문제 UUID (둘 다 있을 때만 메모 틀로 감쌈)
  readonly memo?: SolvingMemo;
  readonly memoPageKey?: string;
  readonly children: ReactNode;
}

/**
 * 풀이 화면 문제 스크롤 영역: 피드백바가 마지막 선택지 카드를 가리지 않게 하단 여백 전환 (풀이 화면 4곳 공통)
 * 메모 상태를 받으면 문제를 메모 틀로 감쌈 (#904)
 */
export default function PracticeQuestionScrollArea({ hasFeedbackBar, memo, memoPageKey, children }: PracticeQuestionScrollAreaProps) {
  // 해설 시트가 떠 있으면 하단 바 + 시트 머리만큼 더 비움 (좁은 화면만)
  const isExplanationPanelOpen = useExplanationHistoryStore((state) => state.isOpen);
  return (
    <div
      className={`flex-1 overflow-y-auto px-4 transition-[padding] duration-300 ${hasFeedbackBar ? "practice-scroll--with-feedback-bar" : "pb-4"} ${
        isExplanationPanelOpen ? "practice-scroll--with-explanation-dock" : ""
      }`}
    >
      {memo && memoPageKey ? (
        <SolvingMemoBoard memo={memo} pageKey={memoPageKey}>
          {children}
        </SolvingMemoBoard>
      ) : (
        children
      )}
    </div>
  );
}
