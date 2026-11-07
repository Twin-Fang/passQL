import { Bar, BarChart, ResponsiveContainer, XAxis } from "recharts";
import type { StudyPatternResponse } from "../../types/api";
import { CHART_COLOR } from "../../constants/chartColors";
import { toCorrectPercent, toMonthDayLabel } from "../../lib/studyStatsPresentation";

// 막대 영역 높이 (px)
const DAILY_CHART_HEIGHT_PIXELS = 140;
// 날짜 축 글자 간격 (일, 한 주마다) > 마지막 칸은 '오늘'
const DATE_LABEL_EVERY_DAYS = 7;
// 쌓은 막대 맨 위 모서리 (px)
const BAR_TOP_RADIUS_PIXELS = 3;
const DAYS_PER_WEEK = 7;

interface StatsStudyRecordSectionProps {
  readonly studyPattern: StudyPatternResponse;
}

/**
 * 최근 4주 학습 (#909, 무료, 앱 StudyRecordSection 대응): 요약 두 줄 + 날짜별 쌓은 막대(맞힘·틀림) + 전체 기록 칸 두 개
 * 4주 동안 풀이가 없으면 막대 대신 안내 한 줄
 */
export default function StatsStudyRecordSection({ studyPattern }: StatsStudyRecordSectionProps) {
  const weekCount = Math.floor(studyPattern.dailyWindowDays / DAYS_PER_WEEK);
  const records = studyPattern.dailyRecords;
  const lastIndex = records.length - 1;
  const chartRows = records.map((record) => ({
    date: record.date,
    correct: record.correctCount,
    wrong: record.solvedCount - record.correctCount,
  }));
  // 축 글자: 첫 칸부터 한 주마다, 마지막 칸 근처(반 주 이내)는 비우고 마지막은 '오늘'
  const tickDates = records
    .filter((_, index) => index === lastIndex || (index % DATE_LABEL_EVERY_DAYS === 0 && lastIndex - index >= DATE_LABEL_EVERY_DAYS / 2))
    .map((record) => record.date);
  const lastDate = records[lastIndex]?.date;

  return (
    <section className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6" aria-label={`최근 ${weekCount}주 학습`}>
      <h2 className="text-base font-bold text-text-primary mb-3">최근 {weekCount}주 학습</h2>
      {studyPattern.recentAttemptCount > 0 ? (
        <>
          <p className="text-subheadline font-semibold text-text-primary">
            {weekCount}주 동안 {studyPattern.recentStudyDayCount}일, {studyPattern.recentAttemptCount}문제 풀었어요
          </p>
          <p className="text-footnote text-text-secondary mt-0.5">{toAccuracyLine(studyPattern)}</p>
          <div className="w-full mt-4" aria-hidden="true">
            <ResponsiveContainer width="100%" height={DAILY_CHART_HEIGHT_PIXELS}>
              <BarChart data={chartRows} margin={{ top: 4, right: 14, left: 14, bottom: 0 }}>
                <XAxis
                  dataKey="date"
                  ticks={tickDates}
                  tickFormatter={(date: string) => (date === lastDate ? "오늘" : toMonthDayLabel(date))}
                  tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }}
                  axisLine={{ stroke: CHART_COLOR.grid }}
                  tickLine={false}
                  interval={0}
                />
                <Bar dataKey="correct" stackId="day" fill={CHART_COLOR.brand} isAnimationActive={false} />
                <Bar
                  dataKey="wrong"
                  stackId="day"
                  fill={CHART_COLOR.brandTint}
                  radius={[BAR_TOP_RADIUS_PIXELS, BAR_TOP_RADIUS_PIXELS, 0, 0]}
                  isAnimationActive={false}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="flex gap-4 mt-2">
            <span className="flex items-center gap-1 text-caption2 text-text-caption">
              <span className="w-2 h-2 rounded-full bg-brand" />
              맞힘
            </span>
            <span className="flex items-center gap-1 text-caption2 text-text-caption">
              <span className="w-2 h-2 rounded-full bg-brand-light" />
              틀림
            </span>
          </div>
        </>
      ) : (
        <p className="text-footnote text-text-secondary">최근 {weekCount}주 동안 푼 문제가 없어요</p>
      )}
      <div className="grid grid-cols-2 gap-2 mt-4">
        <RecordTile label="지금까지 공부한 날" amountText={`${studyPattern.totalStudyDayCount}일`} />
        <RecordTile label="최장 연속 학습" amountText={`${studyPattern.longestStreakDays}일`} />
      </div>
    </section>
  );
}

/** 정답률 한 줄: 서버가 앞 2주와 비교해 준 변화가 있으면 함께 */
function toAccuracyLine(studyPattern: StudyPatternResponse): string {
  const base = `정답률 ${toCorrectPercent(studyPattern.recentCorrectCount, studyPattern.recentAttemptCount)}%`;
  const change = studyPattern.accuracyChangePoints;
  if (change == null) return base;
  if (change === 0) return `${base}, 앞 2주와 같아요`;
  return `${base}, 앞 2주보다 ${Math.abs(change)}%p ${change > 0 ? "올랐어요" : "내려갔어요"}`;
}

function RecordTile({ label, amountText }: { readonly label: string; readonly amountText: string }) {
  return (
    <div className="bg-surface-code rounded-xl p-3">
      <p className="text-caption1 text-text-secondary">{label}</p>
      <p className="text-h2 font-bold text-text-primary tabular-nums mt-0.5">{amountText}</p>
    </div>
  );
}
