import { Bar, BarChart, Cell, ResponsiveContainer, XAxis } from "recharts";
import type { AccuracyDetailResponse, DifficultyStat } from "../../types/api";
import { CHART_COLOR } from "../../constants/chartColors";
import { LOCKED_PREVIEW_CAPTIONS } from "../../constants/proAccessCopy";
import { toMonthDayLabel, toWeeklyRemainingWrongChange } from "../../lib/studyStatsPresentation";
import { toProAccessErrorCode } from "../../lib/proAccess";
import { useAccuracyDetail } from "../../hooks/useStudyStats";
import LockedPreview from "../pro/LockedPreview";
import { AccuracyDetailLockedSample } from "../pro/lockedPreviewSamples";
import { StarRating } from "../StarRating";
import ProgressBar from "../ProgressBar";

// 약한 단계 기준 정답률 (앱 weakAccuracyThreshold 와 같은 60%)
const WEAK_ACCURACY_THRESHOLD = 0.6;
// 주별 남은 오답 막대 높이 (px)
const WRONG_TREND_CHART_HEIGHT_PIXELS = 110;
const BAR_TOP_RADIUS_PIXELS = 3;

/**
 * 난이도별 정답률 + 오답 정리 (#909, 프로, 앱 DifficultyAccuracySection·WrongNoteProgressSection 대응)
 * 무료(403 PRO_REQUIRED) > 잠금 미리보기 한 칸, 불러오는 중 > 스켈레톤, 그 외 오류 > 숨김
 */
export default function StatsAccuracyDetailSection() {
  const { data: accuracyDetail, error, isLoading } = useAccuracyDetail();
  if (isLoading) return <div className="skeleton h-48 rounded-2xl" aria-busy="true" />;
  if (toProAccessErrorCode(error) === "PRO_REQUIRED") {
    return (
      <section aria-label="난이도별 정답률과 오답 정리">
        <h2 className="text-sm text-text-secondary mb-2 px-1">난이도별 정답률과 오답 정리</h2>
        <LockedPreview preview={<AccuracyDetailLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.accuracyDetail} />
      </section>
    );
  }
  if (!accuracyDetail) return null;
  return (
    <>
      {accuracyDetail.difficultyStats.length > 0 && <DifficultyCard difficultyStats={accuracyDetail.difficultyStats} />}
      <WrongNoteCard accuracyDetail={accuracyDetail} />
    </>
  );
}

function DifficultyCard({ difficultyStats }: { readonly difficultyStats: readonly DifficultyStat[] }) {
  return (
    <section className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6" aria-label="난이도별 정답률">
      <div className="flex items-baseline justify-between mb-3">
        <h2 className="text-base font-bold text-text-primary">난이도별 정답률</h2>
        <span className="text-caption1 text-text-caption">전체 기록</span>
      </div>
      <ul className="flex flex-col gap-3">
        {difficultyStats.map((stat) => {
          const percent = Math.round(stat.correctRate * 100);
          const isWeak = stat.correctRate < WEAK_ACCURACY_THRESHOLD;
          return (
            <li key={stat.difficulty} className="flex items-center gap-3" aria-label={`난이도 ${stat.difficulty}, ${stat.solvedCount}문제, 정답률 ${percent}%`}>
              <span aria-hidden="true">
                <StarRating level={stat.difficulty} />
              </span>
              <div className="flex-1 min-w-0" aria-hidden="true">
                <ProgressBar
                  fillPercent={percent}
                  trackClassName="h-1.5 bg-surface-code"
                  fillClassName={isWeak ? "bg-semantic-error" : "bg-brand"}
                />
                <p className="text-caption2 text-text-caption mt-1">{stat.solvedCount}문제</p>
              </div>
              <span aria-hidden="true" className={`w-11 text-right text-subheadline font-semibold tabular-nums ${isWeak ? "text-semantic-error-text" : "text-text-primary"}`}>
                {percent}%
              </span>
            </li>
          );
        })}
      </ul>
      <p className="text-caption2 text-text-caption mt-3">같은 문제는 마지막으로 푼 결과만 세요</p>
    </section>
  );
}

function WrongNoteCard({ accuracyDetail }: { readonly accuracyDetail: AccuracyDetailResponse }) {
  const everWrongCount = accuracyDetail.everWrongQuestionCount;
  const clearedCount = accuracyDetail.clearedWrongQuestionCount;
  const remainingCount = everWrongCount - clearedCount;
  const trend = accuracyDetail.remainingWrongTrend;
  const change = toWeeklyRemainingWrongChange(trend);
  const trendRows = trend.map((week, index) => ({
    label: index === trend.length - 1 ? "이번 주" : toMonthDayLabel(week.weekStartDate),
    count: week.remainingWrongCount,
    isThisWeek: index === trend.length - 1,
  }));
  return (
    <section className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6" aria-label="오답 정리">
      <h2 className="text-base font-bold text-text-primary mb-3">오답 정리</h2>
      {everWrongCount === 0 ? (
        <p className="text-footnote text-text-secondary">아직 틀린 문제가 없어요</p>
      ) : (
        <>
          <p className="text-subheadline font-semibold text-text-primary">
            {clearedCount === 0
              ? `틀린 문제 ${everWrongCount}개, 아직 다시 맞힌 문제는 없어요`
              : `틀린 문제 ${everWrongCount}개 중 ${clearedCount}개를 다시 맞혔어요`}
          </p>
          <ProgressBar
            fillPercent={(clearedCount / everWrongCount) * 100}
            trackClassName="h-1.5 bg-surface-code mt-2"
            fillClassName="bg-semantic-success"
          />
          <p className="text-footnote text-text-secondary mt-2">{toRemainingLine(remainingCount, change)}</p>
          {trendRows.length > 0 && (
            <>
              <p className="text-caption1 font-semibold text-text-secondary mt-4 mb-1">주마다 남은 오답</p>
              <div className="w-full" aria-hidden="true">
                <ResponsiveContainer width="100%" height={WRONG_TREND_CHART_HEIGHT_PIXELS}>
                  <BarChart data={trendRows} margin={{ top: 4, right: 4, left: 4, bottom: 0 }}>
                    <XAxis dataKey="label" interval={0} tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }} axisLine={{ stroke: CHART_COLOR.grid }} tickLine={false} />
                    <Bar dataKey="count" radius={[BAR_TOP_RADIUS_PIXELS, BAR_TOP_RADIUS_PIXELS, 0, 0]} isAnimationActive={false}>
                      {trendRows.map((row) => (
                        <Cell key={row.label} fill={row.isThisWeek ? CHART_COLOR.wrong : CHART_COLOR.rest} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </>
          )}
        </>
      )}
    </section>
  );
}

/** 남은 오답 한 줄: 지난주와 비교 */
function toRemainingLine(remainingCount: number, change: number | null): string {
  const base = `아직 못 맞힌 문제 ${remainingCount}개`;
  if (change == null) return base;
  if (change === 0) return `${base}, 지난주와 같아요`;
  return change < 0 ? `${base}, 지난주보다 ${Math.abs(change)}개 줄었어요` : `${base}, 지난주보다 ${change}개 늘었어요`;
}
