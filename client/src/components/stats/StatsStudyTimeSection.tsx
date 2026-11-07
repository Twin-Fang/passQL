import { Bar, BarChart, Cell, ResponsiveContainer, XAxis } from "recharts";
import type { StudyPatternResponse } from "../../types/api";
import { CHART_COLOR } from "../../constants/chartColors";
import { WEEKDAY_SHORT_NAMES, toSpokenHourLabel } from "../../lib/studyStatsPresentation";

// 요일·시간대 막대 높이 (px)
const PATTERN_CHART_HEIGHT_PIXELS = 96;
// 시간대 축 글자 (0·6·12·18시)
const HOUR_TICKS = [0, 6, 12, 18];
const BAR_TOP_RADIUS_PIXELS = 3;
const DAYS_PER_WEEK = 7;

interface StatsStudyTimeSectionProps {
  readonly studyPattern: StudyPatternResponse;
}

/**
 * 공부하는 시간 (#909, 무료, 앱 StudyTimePatternSection 대응): 최근 12주 요일별·시간대별 막대, 가장 많은 칸만 강조색
 * 서버가 가장 많은 칸을 판정하지 않으면(풀이가 최소 미만) 막대 대신 몇 문제부터 보이는지 안내
 */
export default function StatsStudyTimeSection({ studyPattern }: StatsStudyTimeSectionProps) {
  const weekCount = Math.floor(studyPattern.patternWindowDays / DAYS_PER_WEEK);
  const busiestWeekday = studyPattern.busiestWeekdayIndex;
  const busiestHour = studyPattern.busiestHour;
  const hasPattern = busiestWeekday != null && busiestHour != null;
  const weekdayRows = studyPattern.weekdayAttemptCounts.map((count, index) => ({
    label: WEEKDAY_SHORT_NAMES[index] ?? "",
    count,
    isBusiest: index === busiestWeekday,
  }));
  const hourRows = studyPattern.hourAttemptCounts.map((count, hour) => ({ hour, count, isBusiest: hour === busiestHour }));

  return (
    <section className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6" aria-label="공부하는 시간">
      <div className="flex items-baseline justify-between mb-3">
        <h2 className="text-base font-bold text-text-primary">공부하는 시간</h2>
        <span className="text-caption1 text-text-caption">최근 {weekCount}주</span>
      </div>
      {hasPattern ? (
        <>
          <p className="text-subheadline font-semibold text-text-primary">
            {WEEKDAY_SHORT_NAMES[busiestWeekday]}요일, {toSpokenHourLabel(busiestHour)}대에 가장 많이 풀었어요
          </p>
          <p className="text-caption1 font-semibold text-text-secondary mt-4 mb-1">요일</p>
          <div className="w-full" aria-hidden="true">
            <ResponsiveContainer width="100%" height={PATTERN_CHART_HEIGHT_PIXELS}>
              <BarChart data={weekdayRows} margin={{ top: 4, right: 4, left: 4, bottom: 0 }}>
                <XAxis dataKey="label" tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }} axisLine={{ stroke: CHART_COLOR.grid }} tickLine={false} />
                <Bar dataKey="count" radius={[BAR_TOP_RADIUS_PIXELS, BAR_TOP_RADIUS_PIXELS, 0, 0]} isAnimationActive={false}>
                  {weekdayRows.map((row) => (
                    <Cell key={row.label} fill={row.isBusiest ? CHART_COLOR.brand : CHART_COLOR.brandTint} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
          <p className="text-caption1 font-semibold text-text-secondary mt-4 mb-1">시간대</p>
          <div className="w-full" aria-hidden="true">
            <ResponsiveContainer width="100%" height={PATTERN_CHART_HEIGHT_PIXELS}>
              <BarChart data={hourRows} margin={{ top: 4, right: 4, left: 4, bottom: 0 }}>
                <XAxis
                  dataKey="hour"
                  ticks={HOUR_TICKS}
                  interval={0}
                  tickFormatter={(hour: number) => `${hour}시`}
                  tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }}
                  axisLine={{ stroke: CHART_COLOR.grid }}
                  tickLine={false}
                />
                <Bar dataKey="count" radius={[BAR_TOP_RADIUS_PIXELS, BAR_TOP_RADIUS_PIXELS, 0, 0]} isAnimationActive={false}>
                  {hourRows.map((row) => (
                    <Cell key={row.hour} fill={row.isBusiest ? CHART_COLOR.brand : CHART_COLOR.brandTint} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </>
      ) : (
        <p className="text-footnote text-text-secondary">
          {studyPattern.patternAttemptCount === 0
            ? `최근 ${weekCount}주 동안 푼 문제가 없어요`
            : `${studyPattern.minimumPatternAttemptCount}문제 이상 풀면 자주 공부하는 요일과 시간이 보여요 (지금 ${studyPattern.patternAttemptCount}문제)`}
        </p>
      )}
    </section>
  );
}
