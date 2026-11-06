import ProgressBar from "../ProgressBar";
import { toSubjectShortLabel } from "../../lib/mockExamPresentation";
import type { MockExamSubjectResult, MockExamTopicResult } from "../../types/api";

interface MockExamSubjectAnalysisProps {
  readonly subjects: readonly MockExamSubjectResult[];
  // 서버가 정답률 낮은 순으로 정렬해 내려줌
  readonly topics: readonly MockExamTopicResult[];
}

/** 정답 수 / 문항 수 > 막대 비율 (0문항이면 0) */
function toCorrectPercent(correctCount: number, questionCount: number): number {
  return questionCount > 0 ? (correctCount / questionCount) * 100 : 0;
}

/**
 * 결과 과목·토픽 분석 (프로): 과목 카드 2칸(점수·정답 수·과락 배지·기준 점수) > 토픽별 정답률
 */
export default function MockExamSubjectAnalysis({ subjects, topics }: MockExamSubjectAnalysisProps) {
  return (
    <div className="space-y-6">
      <section aria-label="과목별 점수">
        <h2 className="text-sm text-text-secondary mb-2 px-1">과목별 점수</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {subjects.map((subjectResult) => (
            <div
              key={subjectResult.subject}
              className={`rounded-2xl border bg-surface-card p-4 ${subjectResult.isFailed ? "border-semantic-error-border" : "border-border"}`}
            >
              <div className="flex items-center gap-2">
                <p className="text-xs font-semibold text-text-secondary">{toSubjectShortLabel(subjectResult.subject)}</p>
                {subjectResult.isFailed && (
                  <span className="badge badge-sm border-0 bg-semantic-error text-on-brand font-bold">과락</span>
                )}
              </div>
              <p className="text-sm text-text-primary mt-1 break-keep">{subjectResult.name}</p>
              <p className="mt-2 tabular-nums">
                <span className="text-2xl font-bold text-text-primary">{subjectResult.score}</span>
                <span className="text-sm text-text-secondary"> / {subjectResult.maxScore}점</span>
              </p>
              <p className="text-xs text-text-caption mt-1 tabular-nums">
                정답 {subjectResult.correctCount} / {subjectResult.questionCount}
              </p>
              {subjectResult.isFailed && (
                <p className="text-xs font-semibold text-semantic-error-text mt-2 break-keep">
                  {toSubjectShortLabel(subjectResult.subject)}은 {subjectResult.failBelowScore}점 이상이어야 해요
                </p>
              )}
            </div>
          ))}
        </div>
      </section>

      {topics.length > 0 && (
        <section aria-label="토픽별 정답률">
          <h2 className="text-sm text-text-secondary mb-2 px-1">토픽별 정답률 (낮은 순)</h2>
          <ul className="bg-surface-card border border-border rounded-2xl divide-y divide-border">
            {topics.map((topicResult) => (
              <li key={topicResult.topicUuid} className="p-4 space-y-2">
                <div className="flex items-center justify-between gap-2">
                  <p className="text-sm text-text-primary">{topicResult.topicName}</p>
                  <p className="text-xs text-text-secondary tabular-nums">
                    {topicResult.correctCount} / {topicResult.questionCount}
                  </p>
                </div>
                <ProgressBar
                  fillPercent={toCorrectPercent(topicResult.correctCount, topicResult.questionCount)}
                  trackClassName="h-1.5 bg-border"
                  fillClassName="bg-brand"
                />
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}
