import { ChoiceCard } from "../ChoiceCard";
import type { ChoiceItem, ExecuteResult } from "../../types/api";

interface QuestionChoiceListProps {
  readonly choices: readonly ChoiceItem[];
  readonly selectedKey: string | null;
  // 연습 모드 제출 후 true — 실행 버튼·결과 표시, 선택 변경 막음
  readonly showExecution: boolean;
  readonly isExecutableQuestion: boolean;
  readonly executeCache: Readonly<Record<string, ExecuteResult>>;
  readonly executingKeys: ReadonlySet<string>;
  readonly onSelect: (choiceKey: string, sql: string) => void;
  readonly onExecute: (choiceKey: string, sql: string) => void;
  readonly onAskAi: (choiceKey: string, errorCode: string, errorMessage: string) => void;
}

/**
 * 풀이 선택지 카드 목록
 */
export default function QuestionChoiceList({
  choices,
  selectedKey,
  showExecution,
  isExecutableQuestion,
  executeCache,
  executingKeys,
  onSelect,
  onExecute,
  onAskAi,
}: QuestionChoiceListProps) {
  return (
    <section className="mt-4 space-y-3">
      {choices.map((choice) => (
        <ChoiceCard
          key={choice.key}
          choice={choice}
          isSelected={selectedKey === choice.key}
          // showExecution=true(제출 후)일 때만 실행 결과 표시
          cached={showExecution ? executeCache[choice.key] : undefined}
          // 제출 후(showExecution=true)에만 실행 버튼 표시
          isExecutable={showExecution && isExecutableQuestion}
          isExecuting={executingKeys.has(choice.key)}
          // 제출 후 선택 변경 방지 — showExecution이면 no-op
          onSelect={showExecution ? () => {} : onSelect}
          onExecute={onExecute}
          onAskAi={onAskAi}
        />
      ))}
    </section>
  );
}
