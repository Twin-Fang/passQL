import { CartesianGrid, Line, LineChart, ReferenceLine, ResponsiveContainer, XAxis, YAxis } from "recharts";
import LockedPreview from "../pro/LockedPreview";
import { MockExamScoreTrendLockedSample } from "../pro/lockedPreviewSamples";
import { LOCKED_PREVIEW_CAPTIONS } from "../../constants/proAccessCopy";
import { CHART_COLOR } from "../../constants/chartColors";
import { toProAccessErrorCode } from "../../lib/proAccess";
import { formatMonthDay } from "../../lib/mockExamPresentation";
import { useMockExamHistory } from "../../hooks/useMockExam";

// 차트 높이 (px)
const TREND_CHART_HEIGHT_PIXELS = 200;

interface MockExamScoreTrendSectionProps {
  // y축 상한 (서버 examRule.maxScore)
  readonly maxScore: number;
}

/**
 * 점수 추이 (프로): 채점된 응시 시간순 꺾은선 + 합격선 가로줄 + 최근 응시 목록
 * 무료(403 PRO_REQUIRED) > 잠금 미리보기, 그 외 오류 > 숨김 (목록 화면 본문은 유지)
 */
export default function MockExamScoreTrendSection({ maxScore }: MockExamScoreTrendSectionProps) {
  const { data: history, error, isLoading } = useMockExamHistory();
  const isProRequired = toProAccessErrorCode(error) === "PRO_REQUIRED";

  if (isLoading) return <div className="skeleton h-48 rounded-2xl" aria-busy="true" />;
  if (isProRequired) {
    return (
      <section aria-label="점수 추이">
        <h2 className="text-sm text-text-secondary mb-2 px-1">점수 추이</h2>
        <LockedPreview preview={<MockExamScoreTrendLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.mockExamScoreTrend} />
      </section>
    );
  }
  if (!history) return null;

  const chartPoints = history.attempts.map((attempt, index) => ({
    key: `${attempt.attemptUuid}`,
    label: `${index + 1}`,
    score: attempt.totalScore,
  }));
  const recentAttempts = [...history.attempts].reverse().slice(0, 5);

  return (
    <section aria-label="점수 추이">
      <h2 className="text-sm text-text-secondary mb-2 px-1">점수 추이</h2>
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-5">
        {history.attempts.length === 0 ? (
          <p className="text-sm text-text-secondary text-center py-6">채점된 시험이 생기면 점수 변화를 보여 드려요</p>
        ) : (
          <>
            <div className="w-full" aria-hidden="true">
              <ResponsiveContainer width="100%" height={TREND_CHART_HEIGHT_PIXELS}>
                <LineChart data={chartPoints} margin={{ top: 8, right: 12, left: -16, bottom: 0 }}>
                  <CartesianGrid stroke={CHART_COLOR.grid} strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="label" tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }} />
                  <YAxis domain={[0, maxScore]} tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }} />
                  <ReferenceLine
                    y={history.passScore}
                    stroke={CHART_COLOR.passLine}
                    strokeDasharray="4 4"
                    label={{ value: `합격 ${history.passScore}`, position: "insideTopRight", fontSize: 11, fill: CHART_COLOR.passLine }}
                  />
                  <Line type="monotone" dataKey="score" stroke={CHART_COLOR.brand} strokeWidth={2} dot={{ r: 3 }} isAnimationActive={false} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            {/* 차트 대신 읽을 최근 응시 목록 (최신 5개) */}
            <ul className="mt-3 divide-y divide-border" aria-label="최근 응시 점수">
              {recentAttempts.map((attempt) => (
                <li key={attempt.attemptUuid} className="flex items-center gap-2 py-2 text-sm">
                  <span className="flex-1 min-w-0 truncate text-text-primary">{attempt.title}</span>
                  <span className="text-xs text-text-caption">{formatMonthDay(attempt.submittedAt)}</span>
                  <span className="tabular-nums font-semibold text-text-primary">{attempt.totalScore}점</span>
                  <span
                    className={`badge badge-sm border-0 ${attempt.isPassed ? "bg-semantic-success-light text-semantic-success-text" : "bg-semantic-error-light text-semantic-error-text"}`}
                  >
                    {attempt.isPassed ? "합격" : "불합격"}
                  </span>
                </li>
              ))}
            </ul>
          </>
        )}
      </div>
    </section>
  );
}
