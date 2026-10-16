import { GitCompare } from "lucide-react";
import PlayIcon from "../PlayIcon";
import SqlChoiceAccordionItem from "./SqlChoiceAccordionItem";
import type { ChoiceItem, ExecuteResult } from "../../types/api";

interface SqlComparisonSectionProps {
  readonly sqlChoices: readonly ChoiceItem[];
  readonly correctKey: string;
  readonly selectedKey: string;
  readonly openKeys: ReadonlySet<string>;
  readonly executingKeys: ReadonlySet<string>;
  readonly resultCache: Readonly<Record<string, ExecuteResult>>;
  readonly executionErrorByKey: Readonly<Record<string, string>>;
  readonly onToggle: (key: string) => void;
  readonly onExecute: (choice: ChoiceItem) => void;
  readonly onExecuteAll: () => void;
}

/**
 * EXECUTABLE 채점 결과: SQL 실행 비교 헤더(모두 실행) + 선택지 아코디언 목록
 */
export default function SqlComparisonSection({
  sqlChoices,
  correctKey,
  selectedKey,
  openKeys,
  executingKeys,
  resultCache,
  executionErrorByKey,
  onToggle,
  onExecute,
  onExecuteAll,
}: SqlComparisonSectionProps) {
  return (
    <section className="space-y-2 feedback-card-anim-3">
      {/* 섹션 헤더: 레이블 + 모두 실행 버튼 */}
      <div className="flex items-center justify-between px-0.5">
        <div className="flex items-center gap-1.5">
          <GitCompare size={13} className="text-base-content/60 shrink-0" />
          <p className="text-xs text-base-content/60 uppercase tracking-widest font-semibold">
            SQL 실행 비교
          </p>
        </div>
        <button
          type="button"
          className="btn-run-all"
          onClick={onExecuteAll}
        >
          <PlayIcon />
          모두 실행하기
        </button>
      </div>

      {/* 선택지 아코디언 목록 */}
      {sqlChoices.map((choice) => (
        <SqlChoiceAccordionItem
          key={choice.key}
          choice={choice}
          isAnswer={choice.key === correctKey}
          isMyChoice={choice.key === selectedKey}
          isOpen={openKeys.has(choice.key)}
          isRunning={executingKeys.has(choice.key)}
          cachedResult={resultCache[choice.key]}
          executionError={executionErrorByKey[choice.key]}
          onToggle={onToggle}
          onExecute={onExecute}
        />
      ))}
    </section>
  );
}
