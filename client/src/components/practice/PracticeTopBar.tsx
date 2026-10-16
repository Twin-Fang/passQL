import type { ReactNode } from "react";

interface PracticeTopBarProps {
  // 왼쪽 나가기 버튼 아이콘 (홈 또는 뒤로가기)
  readonly exitIcon: ReactNode;
  readonly exitAriaLabel?: string;
  readonly onExitClick: () => void;
  // 가운데 제목 (진행 번호 등)
  readonly title: ReactNode;
  // 오른쪽 칸 (없으면 빈 칸)
  readonly trailing?: ReactNode;
}

/**
 * 풀이 화면 상단 3칸 바: 나가기 버튼 / 제목 / 오른쪽 칸 (풀이 화면 4곳 공통)
 */
export default function PracticeTopBar({ exitIcon, exitAriaLabel, onExitClick, title, trailing }: PracticeTopBarProps) {
  return (
    <div className="grid grid-cols-3 items-center mb-2">
      <div className="justify-self-start">
        <button
          type="button"
          aria-label={exitAriaLabel}
          className="w-8 h-8 flex items-center justify-center rounded-xl hover:bg-border transition-colors"
          onClick={onExitClick}
        >
          {exitIcon}
        </button>
      </div>
      <span className="text-sm font-semibold text-text-secondary text-center">
        {title}
      </span>
      {trailing ?? <div />}
    </div>
  );
}
