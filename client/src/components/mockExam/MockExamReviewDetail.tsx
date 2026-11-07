import MarkdownText from "../MarkdownText";
import { ResultMatchTable } from "../ResultMatchTable";
import StemBlocks from "../question/StemBlocks";
import RationaleCard from "../answerFeedback/RationaleCard";
import { isResultTableChoiceBody } from "../../lib/choiceBodyKind";
import type { MockExamChoice, MockExamQuestionReview } from "../../types/api";

interface MockExamReviewDetailProps {
  readonly review: MockExamQuestionReview;
}

/** 보기 body 종류별 표시: SQL 고정폭 / 결과표(JSON 배열) / 개념 마크다운 */
function ChoiceBodyContent({ choice }: { readonly choice: MockExamChoice }) {
  if (choice.kind === "SQL") {
    return <p className="text-mono text-sm leading-relaxed whitespace-pre-wrap wrap-break-word">{choice.body}</p>;
  }
  if (isResultTableChoiceBody(choice.body)) return <ResultMatchTable body={choice.body} />;
  return <MarkdownText text={choice.body} className="text-sm text-body" />;
}

/** 보기 > 카드 모양 (정답 초록, 고른 오답 빨강, 나머지 기본) */
function toChoiceCardClassName(choice: MockExamChoice, review: MockExamQuestionReview): string {
  if (choice.key === review.correctChoiceKey) return "ans-card-correct";
  if (choice.key === review.selectedChoiceKey) return "ans-card-wrong";
  return "ans-card-neutral";
}

/** 보기 머리 표시 ("정답 · 내 답") */
function toChoiceTags(choice: MockExamChoice, review: MockExamQuestionReview): string[] {
  return [
    ...(choice.key === review.correctChoiceKey ? ["정답"] : []),
    ...(choice.key === review.selectedChoiceKey ? ["내 답"] : []),
  ];
}

/**
 * 문항 해설 (프로): 지문(테이블 포함) > 보기별 채점(정답·내 답) + 보기 근거 > 요약 해설
 * 저장된 근거·요약만 표시 (AI 호출 없음)
 */
export default function MockExamReviewDetail({ review }: MockExamReviewDetailProps) {
  return (
    <div className="space-y-3 pt-1">
      <StemBlocks stem={review.stem} schemaTables={review.schemaTables} schemaDdl={review.schemaDisplay} />
      {review.selectedChoiceKey === null && <p className="text-xs font-semibold text-text-caption">풀지 않은 문항이에요</p>}

      <ol className="space-y-2" aria-label="보기 채점">
        {review.choices.map((choice, index) => {
          const choiceTags = toChoiceTags(choice, review);
          return (
            <li key={choice.key} className={toChoiceCardClassName(choice, review)}>
              <p className="text-xs font-semibold text-text-secondary mb-1.5">
                보기 {index + 1}
                {choiceTags.length > 0 && <span className="ml-1.5 text-text-primary">· {choiceTags.join(" · ")}</span>}
              </p>
              <ChoiceBodyContent choice={choice} />
              {choice.rationale && <p className="mt-2 text-xs text-text-secondary leading-relaxed break-keep">{choice.rationale}</p>}
            </li>
          );
        })}
      </ol>

      {review.explanationSummary && <RationaleCard rationale={review.explanationSummary} />}
    </div>
  );
}
