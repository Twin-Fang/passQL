import { useState } from "react";
import { CloudOff } from "lucide-react";
import QuestionStemToggle from "../questionDetail/QuestionStemToggle";
import { ChoiceCard } from "../ChoiceCard";
import { toSubjectShortLabel } from "../../lib/mockExamPresentation";
import { MOCK_EXAM_UNSAVED_LABEL } from "../../constants/mockExamCopy";
import type { MockExamSheetQuestion } from "../../types/api";

interface MockExamQuestionViewProps {
  readonly question: MockExamSheetQuestion;
  readonly selectedChoiceKey: string | null;
  // 서버 저장 실패 문항 (다음 저장·제출 때 함께 보냄)
  readonly isUnsaved: boolean;
  readonly onChoicePressed: (choiceKey: string) => void;
}

// 풀이 중 보기 실행·결과 없음 > 실행 콜백 자리 채움
const ignoreChoiceExecution = () => {};

/**
 * 모의고사 문항 1개: 과목·토픽 머리 > 지문(테이블 포함) > 보기 (연습 화면 지문·테이블·보기 카드 재사용)
 * 실전처럼 정답·실행·해설 없음, 보기 다시 누르면 선택 해제 (호출부 판단)
 */
export default function MockExamQuestionView({
  question,
  selectedChoiceKey,
  isUnsaved,
  onChoicePressed,
}: MockExamQuestionViewProps) {
  const [isStemOpen, setIsStemOpen] = useState(true);

  return (
    <article aria-label={`${question.questionNumber}번 문항`} className="pb-6">
      <div className="flex items-center gap-2 flex-wrap">
        <span className="text-base font-bold text-text-primary tabular-nums">{question.questionNumber}번</span>
        <span className="badge badge-sm border-0 bg-surface-code text-text-secondary">
          {toSubjectShortLabel(question.subject)}
        </span>
        {question.topicName && <span className="badge-topic">{question.topicName}</span>}
        {isUnsaved && (
          <span className="ml-auto inline-flex items-center gap-1 text-xs font-semibold text-semantic-warning-text" role="status">
            <CloudOff size={13} aria-hidden="true" />
            {MOCK_EXAM_UNSAVED_LABEL}
          </span>
        )}
      </div>

      <QuestionStemToggle
        stem={question.stem}
        isStemOpen={isStemOpen}
        onToggle={() => setIsStemOpen((previous) => !previous)}
        schemaTables={question.schemaTables}
        schemaDdl={question.schemaDisplay}
      />

      <section className="mt-4 space-y-3" aria-label="보기">
        {question.choices.map((choice) => (
          <ChoiceCard
            key={choice.key}
            choice={choice}
            isSelected={selectedChoiceKey === choice.key}
            cached={undefined}
            isExecutable={false}
            isExecuting={false}
            onSelect={onChoicePressed}
            onExecute={ignoreChoiceExecution}
          />
        ))}
      </section>
    </article>
  );
}
