import { useMemo, useState } from "react";
import PracticeQuestionResultRow from "./PracticeQuestionResultRow";
import type { PracticeQuestionResult, QuestionSummary } from "../../types/api";

interface PracticeQuestionResultListProps {
  readonly results: readonly PracticeQuestionResult[];
  readonly questions: readonly QuestionSummary[];
  readonly sessionId: string | undefined;
  // 인덱스별 카드 등장 여부
  readonly visibleCards: readonly boolean[];
}

/**
 * 문제별 결과 목록: 구분선 + 제목 > 아코디언 행 (한 번에 1개만 펼침)
 */
export default function PracticeQuestionResultList({
  results,
  questions,
  sessionId,
  visibleCards,
}: PracticeQuestionResultListProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  // questionUuid > 지문 미리보기 (행마다 find 하던 O(n²) 제거)
  const stemPreviewByQuestionUuid = useMemo(
    () => new Map(questions.map((question) => [question.questionUuid, question.stemPreview ?? undefined])),
    [questions],
  );

  return (
    <>
      <div className="w-full h-px bg-border mb-3" />
      <div className="flex items-center justify-between mb-3">
        <p className="text-sm font-medium text-text-caption">
          문제별 결과
        </p>
      </div>
      <div className="flex flex-col gap-2">
        {results.map((result, i) => {
          const isOpen = openIndex === i;
          return (
            <PracticeQuestionResultRow
              key={result.questionUuid}
              result={result}
              questionNumber={i + 1}
              stemPreview={stemPreviewByQuestionUuid.get(result.questionUuid)}
              sessionId={sessionId}
              isOpen={isOpen}
              isVisible={!!visibleCards[i]}
              onToggle={() => setOpenIndex(isOpen ? null : i)}
            />
          );
        })}
      </div>
    </>
  );
}
