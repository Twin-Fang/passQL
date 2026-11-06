import { AlertTriangle, Flag, Hourglass } from "lucide-react";
import ProgressBar from "../ProgressBar";
import type { AiAnalysisReadiness, AiExamForecast } from "../../types/api";

// 판정 > 배지 색 (과락 위험·합격선 아래 빨강, 근처 주황, 합격권 초록)
const VERDICT_BADGE_CLASS_BY_VERDICT: Readonly<Record<AiExamForecast["verdict"], string>> = {
  SUBJECT_FAIL_RISK: "text-semantic-error-text bg-semantic-error-light",
  BELOW_PASS: "text-semantic-error-text bg-semantic-error-light",
  BORDERLINE: "text-semantic-warning-text bg-semantic-warning-light",
  PASS_LIKELY: "text-semantic-success-text bg-semantic-success-light",
};

/** 과목 한 줄: 과목 이름 > 막대 > 예상/문항 수 (과락 위험이면 주의 색) */
function SubjectScoreRow({
  subjectName,
  expectedCount,
  questionCount,
  isFailRisk,
}: {
  readonly subjectName: string;
  readonly expectedCount: number;
  readonly questionCount: number;
  readonly isFailRisk: boolean;
}) {
  const fillPercent = questionCount === 0 ? 0 : (expectedCount / questionCount) * 100;
  return (
    <div className="flex items-center gap-2">
      <span className="text-caption1 text-text-secondary w-10 shrink-0">{subjectName}</span>
      <ProgressBar
        fillPercent={fillPercent}
        trackClassName="h-1.5 bg-border"
        fillClassName={`${isFailRisk ? "bg-semantic-warning" : "bg-brand"} transition-all duration-700`}
      />
      <span
        className={`text-caption1 font-semibold tabular-nums shrink-0 ${isFailRisk ? "text-semantic-warning-text" : "text-text-primary"}`}
      >
        {expectedCount}/{questionCount}
      </span>
    </div>
  );
}

/** 예상 점수 묶음 (#862): 머리(예상 점수 + 판정) > 큰 점수 > 과목별 막대 2줄 > 판정 설명 */
export function StatsAiForecast({ forecast }: { readonly forecast: AiExamForecast }) {
  const hasFailRisk = forecast.isSubjectOneFailRisk || forecast.isSubjectTwoFailRisk;
  return (
    <div className="bg-surface rounded-xl p-3 space-y-2">
      <div className="flex items-center justify-between gap-2">
        <span className="text-caption1 font-semibold text-text-secondary">예상 점수</span>
        <span
          className={`text-caption2 font-semibold px-1.5 py-px rounded-full ${VERDICT_BADGE_CLASS_BY_VERDICT[forecast.verdict]}`}
        >
          {forecast.verdictLabel}
        </span>
      </div>
      <p className="text-text-primary">
        <span className="text-h1 text-2xl tabular-nums">{forecast.expectedScore}</span>
        <span className="text-caption1 text-text-secondary">점 / 100</span>
      </p>
      <SubjectScoreRow
        subjectName="1과목"
        expectedCount={forecast.subjectOneExpectedCount}
        questionCount={forecast.subjectOneQuestionCount}
        isFailRisk={forecast.isSubjectOneFailRisk}
      />
      <SubjectScoreRow
        subjectName="2과목"
        expectedCount={forecast.subjectTwoExpectedCount}
        questionCount={forecast.subjectTwoQuestionCount}
        isFailRisk={forecast.isSubjectTwoFailRisk}
      />
      {forecast.detail && (
        <p
          className={`flex items-start gap-1.5 text-caption1 ${hasFailRisk ? "text-semantic-warning-text" : "text-text-secondary"}`}
        >
          {hasFailRisk ? (
            <AlertTriangle size={13} className="shrink-0 mt-0.5" aria-hidden="true" />
          ) : (
            <Flag size={13} className="shrink-0 mt-0.5" aria-hidden="true" />
          )}
          <span>{forecast.detail}</span>
        </p>
      )}
    </div>
  );
}

/** 예상 점수 근거 부족 안내 (예: 1과목 2문제 더 풀면 예상 점수를 알려 드려요) */
export function StatsAiForecastHint({ hint }: { readonly hint: string }) {
  return (
    <p className="flex items-start gap-1.5 bg-surface rounded-xl p-3 text-caption1 text-text-secondary">
      <Hourglass size={13} className="shrink-0 mt-0.5" aria-hidden="true" />
      <span>{hint}</span>
    </p>
  );
}

/** 데이터 부족 안내 (#862): 서버 문구 > 진행 토픽 + "지금 N/5" > 목표 칸 (푼 칸만 강조) */
export function StatsAiReadiness({ readiness }: { readonly readiness: AiAnalysisReadiness }) {
  const solvedCount = Math.min(Math.max(readiness.solvedCount, 0), readiness.targetCount);
  const segmentIndexes = Array.from({ length: readiness.targetCount }, (_, index) => index);
  return (
    <div className="bg-surface rounded-xl p-3 space-y-2">
      <p className="text-sm text-text-primary leading-relaxed">{readiness.message}</p>
      <div className="flex items-center justify-between gap-2 text-caption1">
        <span className="text-text-secondary truncate">{readiness.topicName ?? ""}</span>
        <span className="font-semibold text-brand tabular-nums shrink-0">
          지금 {solvedCount}/{readiness.targetCount}
        </span>
      </div>
      <div className="flex gap-1" aria-hidden="true">
        {segmentIndexes.map((segmentIndex) => (
          <span
            key={segmentIndex}
            className={`h-1.5 flex-1 rounded-full ${segmentIndex < solvedCount ? "bg-brand" : "bg-border"}`}
          />
        ))}
      </div>
    </div>
  );
}
