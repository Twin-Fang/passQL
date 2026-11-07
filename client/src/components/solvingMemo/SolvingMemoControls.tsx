import { Eraser, Highlighter, Pen, PenLine, Undo2, type LucideIcon } from "lucide-react";
import type { SolvingMemo } from "../../hooks/useSolvingMemo";
import type { SolvingMemoInk, SolvingMemoTool } from "../../lib/solvingMemoStroke";

interface SolvingMemoControlsProps {
  readonly memo: SolvingMemo;
  // 지금 보이는 문항 (메모 있음 점·되돌리기 대상)
  readonly pageKey: string;
}

const TOOL_ITEMS: readonly { readonly tool: SolvingMemoTool; readonly Icon: LucideIcon; readonly label: string }[] = [
  { tool: "pen", Icon: Pen, label: "펜" },
  { tool: "highlighter", Icon: Highlighter, label: "형광펜" },
  { tool: "eraser", Icon: Eraser, label: "지우개" },
];

// 색 칸: 바탕·고리 색 클래스 (tokens.css --color-memo-ink-*)
const INK_ITEMS: readonly { readonly ink: SolvingMemoInk; readonly label: string; readonly colorClassName: string }[] = [
  { ink: "red", label: "빨강 펜", colorClassName: "bg-memo-ink-red text-memo-ink-red" },
  { ink: "blue", label: "파랑 펜", colorClassName: "bg-memo-ink-blue text-memo-ink-blue" },
  { ink: "black", label: "검정 펜", colorClassName: "bg-memo-ink-black text-memo-ink-black" },
];

/**
 * 메모 켜고 끄기 (#904, 앱 PassqlMemoScope 대응): 끔이면 오른쪽 아래 펜 버튼(메모 있으면 빨간 점),
 * 켬이면 도구 막대(펜·형광펜·지우개·되돌리기 | 색 3개 | 완료). 하단 고정 바 바로 위에 떠 있음
 */
export default function SolvingMemoControls({ memo, pageKey }: SolvingMemoControlsProps) {
  const hasMemo = memo.hasStrokesOn(pageKey);
  const canUndo = memo.canUndoOn(pageKey);
  return (
    <div className="solving-memo-controls fixed inset-x-0 z-10 pointer-events-none">
      <div className="mx-auto max-w-120 px-4 flex justify-end">
        {memo.isMemoMode ? (
          <div
            role="toolbar"
            aria-label="메모 도구"
            className="solving-memo-surface pointer-events-auto w-full rounded-full px-2 py-1 flex items-center justify-between gap-1"
          >
            {TOOL_ITEMS.map(({ tool, Icon, label }) => {
              const isSelected = memo.selectedTool === tool;
              return (
                <button
                  key={tool}
                  type="button"
                  aria-label={label}
                  aria-pressed={isSelected}
                  className={`btn btn-ghost btn-circle shrink-0 ${isSelected ? "bg-brand-light text-brand" : "text-text-secondary"}`}
                  onClick={() => memo.selectTool(tool)}
                >
                  <Icon size={20} aria-hidden="true" />
                </button>
              );
            })}
            <button
              type="button"
              aria-label="되돌리기"
              className="btn btn-ghost btn-circle shrink-0 text-text-secondary"
              disabled={!canUndo}
              onClick={() => memo.undo(pageKey)}
            >
              <Undo2 size={20} aria-hidden="true" />
            </button>
            <div className="flex shrink-0">
              {INK_ITEMS.map(({ ink, label, colorClassName }) => {
                const isSelected = memo.selectedTool === "pen" && memo.selectedInk === ink;
                return (
                  <button
                    key={ink}
                    type="button"
                    aria-label={label}
                    aria-pressed={isSelected}
                    className="flex items-center justify-center w-7 h-11"
                    onClick={() => memo.selectInk(ink)}
                  >
                    <span className={`size-5 rounded-full ${colorClassName} ${isSelected ? "solving-memo-ink-dot--selected" : ""}`} />
                  </button>
                );
              })}
            </div>
            <button
              type="button"
              aria-label="메모 끄기"
              className="btn btn-sm shrink-0 rounded-full border-none bg-brand text-on-brand"
              onClick={memo.toggleMemoMode}
            >
              완료
            </button>
          </div>
        ) : (
          <button
            type="button"
            aria-label={hasMemo ? "메모 켜기, 메모 있음" : "메모 켜기"}
            className="solving-memo-surface pointer-events-auto relative size-12 rounded-full flex items-center justify-center text-brand"
            onClick={memo.toggleMemoMode}
          >
            <PenLine size={22} aria-hidden="true" />
            {hasMemo && <span className="solving-memo-has-memo-dot absolute top-1.5 right-1.5 size-3 rounded-full bg-semantic-error" />}
          </button>
        )}
      </div>
    </div>
  );
}
