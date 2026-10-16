import type { ReactNode } from "react";

interface PracticeQuestionScrollAreaProps {
  // 피드백바 표시 중 여부 — 바 높이(~200px)만큼 하단 여백 확보
  readonly hasFeedbackBar: boolean;
  readonly children: ReactNode;
}

/**
 * 풀이 화면 문제 스크롤 영역: 피드백바가 마지막 선택지 카드를 가리지 않게 하단 여백 전환 (풀이 화면 4곳 공통)
 */
export default function PracticeQuestionScrollArea({ hasFeedbackBar, children }: PracticeQuestionScrollAreaProps) {
  return (
    <div className={`flex-1 overflow-y-auto px-4 transition-[padding] duration-300 ${hasFeedbackBar ? "pb-52" : "pb-4"}`}>
      {children}
    </div>
  );
}
