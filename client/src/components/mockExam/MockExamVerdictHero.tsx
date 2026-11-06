import { Award, CircleAlert } from "lucide-react";
import { formatDurationLabel } from "../../lib/formatDurationLabel";
import { toSubmitReasonNote, toVerdictReasonLine } from "../../lib/mockExamPresentation";
import type { MockExamResultResponse } from "../../types/api";

interface MockExamVerdictHeroProps {
  readonly result: MockExamResultResponse;
}

/**
 * 결과 첫 화면: 합격/불합격 큰 글자 > 총점/만점 > 이유 한 줄 > 정답 수·푼 시간
 * 합격 아이콘 등장 연출은 동작 줄이기 설정이면 정지 (reduced-motion.css)
 */
export default function MockExamVerdictHero({ result }: MockExamVerdictHeroProps) {
  const VerdictIcon = result.isPassed ? Award : CircleAlert;
  const submitReasonNote = toSubmitReasonNote(result);
  return (
    <section
      aria-label="시험 결과"
      className={`rounded-2xl border px-5 py-7 text-center ${
        result.isPassed ? "bg-semantic-success-light border-semantic-success-border" : "bg-semantic-error-light border-semantic-error-border"
      }`}
    >
      <p className="text-xs text-text-secondary">{result.title}</p>
      <div className="mt-3 flex items-center justify-center gap-2">
        <VerdictIcon
          size={32}
          aria-hidden="true"
          className={result.isPassed ? "text-semantic-success-text animate-sparkle-pop" : "text-semantic-error-text"}
        />
        <h1 className={`text-h1 ${result.isPassed ? "text-semantic-success-text" : "text-semantic-error-text"}`}>
          {result.isPassed ? "합격" : "불합격"}
        </h1>
      </div>
      <p className="mt-2 tabular-nums text-text-primary">
        <span className="text-5xl font-bold">{result.totalScore}</span>
        <span className="text-lg text-text-secondary"> / {result.maxScore}점</span>
      </p>
      <p className="mt-2 text-sm font-semibold text-text-primary break-keep">{toVerdictReasonLine(result)}</p>
      <p className="mt-3 text-xs text-text-secondary tabular-nums">
        정답 {result.correctCount} / {result.questionCount} · 푼 시간 {formatDurationLabel(result.elapsedSeconds * 1000)}
      </p>
      {submitReasonNote && <p className="mt-1 text-xs text-text-caption">{submitReasonNote}</p>}
    </section>
  );
}
