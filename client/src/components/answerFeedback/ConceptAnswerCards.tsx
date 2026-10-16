interface ConceptAnswerCardsProps {
  readonly isCorrect: boolean;
  readonly selectedBody: string | null;
  readonly correctBody: string | null;
}

/**
 * CONCEPT_ONLY 채점 결과: 오답이면 내가 선택한 답 + 정답, 정답이면 정답 카드 1개
 */
export default function ConceptAnswerCards({ isCorrect, selectedBody, correctBody }: ConceptAnswerCardsProps) {
  return (
    <div className="space-y-2 feedback-card-anim-2">
      {!isCorrect && selectedBody && (
        <div className="ans-card-wrong">
          <p className="text-xs font-semibold uppercase tracking-widest text-error/70 mb-1.5">
            내가 선택한 답
          </p>
          <p className="text-sm text-base-content leading-relaxed">{selectedBody}</p>
        </div>
      )}
      {correctBody && (
        <div className="ans-card-correct">
          <p className="text-xs font-semibold uppercase tracking-widest text-success/70 mb-1.5">
            {isCorrect ? "내가 선택한 답 · 정답" : "정답"}
          </p>
          <p className="text-sm text-base-content leading-relaxed">{correctBody}</p>
        </div>
      )}
    </div>
  );
}
