import type {
  QuestionNumberCell,
  QuestionNumberCellTone,
  SubjectGroup,
} from "../../lib/mockExamPresentation";

interface MockExamQuestionNumberGridProps {
  readonly groups: readonly SubjectGroup<QuestionNumberCell>[];
  // 없으면 누를 수 없는 표 (무료 결과 정오표)
  readonly onSelectQuestion?: (questionNumber: number) => void;
}

// 칸 상태 > 색 (토큰만)
const CELL_TONE_CLASS_NAMES: Readonly<Record<QuestionNumberCellTone, string>> = {
  answered: "bg-brand text-on-brand border-brand",
  unanswered: "bg-surface-card text-text-secondary border-border",
  correct: "bg-semantic-success-light text-semantic-success-text border-semantic-success-border",
  wrong: "bg-semantic-error-light text-semantic-error-text border-semantic-error-border",
  skipped: "bg-surface-code text-text-caption border-border",
};

const CELL_BASE_CLASS_NAME =
  "relative h-11 w-full rounded-lg border text-sm font-semibold tabular-nums flex items-center justify-center";

/**
 * 문항 번호판 (풀이 번호판·결과 정오표 공통): 과목별 묶음 > 칸(상태 색·표시 점·현재 테두리)
 * 칸 높이 44px (터치 최소), 키보드 Tab 이동·Enter 선택, 포커스 테두리 표시
 */
export default function MockExamQuestionNumberGrid({ groups, onSelectQuestion }: MockExamQuestionNumberGridProps) {
  return (
    <div className="space-y-4">
      {groups.map((group) => (
        <section key={group.subject} aria-label={`${group.label} 문항`}>
          <p className="text-xs font-semibold text-text-secondary mb-2">
            {group.label} · {group.items.length}문항
          </p>
          <ul className="grid grid-cols-5 sm:grid-cols-10 gap-2">
            {group.items.map((cell) => {
              const cellClassName = `${CELL_BASE_CLASS_NAME} ${CELL_TONE_CLASS_NAMES[cell.tone]} ${
                cell.isCurrent ? "ring-2 ring-brand ring-offset-2 ring-offset-surface-card" : ""
              }`;
              const cellContent = (
                <>
                  {cell.questionNumber}
                  {cell.isFlagged && (
                    <span aria-hidden="true" className="absolute top-1 right-1 w-1.5 h-1.5 rounded-full bg-semantic-warning" />
                  )}
                </>
              );
              return (
                <li key={cell.questionNumber}>
                  {onSelectQuestion ? (
                    <button
                      type="button"
                      aria-label={cell.ariaLabel}
                      aria-current={cell.isCurrent ? "step" : undefined}
                      className={`${cellClassName} cursor-pointer focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand`}
                      onClick={() => onSelectQuestion(cell.questionNumber)}
                    >
                      {cellContent}
                    </button>
                  ) : (
                    <span role="img" aria-label={cell.ariaLabel} className={cellClassName}>
                      {cellContent}
                    </span>
                  )}
                </li>
              );
            })}
          </ul>
        </section>
      ))}
    </div>
  );
}
