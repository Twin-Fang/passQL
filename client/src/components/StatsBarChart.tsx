import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  ResponsiveContainer,
  Cell,
} from "recharts";
import type { TopicStat } from "../types/api";
import { CHART_COLOR, CHART_COLOR_BY_TONE } from "../constants/chartColors";
import { toCorrectRateTone } from "../constants/correctRateTone";

// 차트 높이 (px): 최소 256, 토픽 1개당 32
const MINIMUM_CHART_HEIGHT_PIXELS = 256;
const ROW_HEIGHT_PIXELS = 32;

interface StatsBarChartProps {
  readonly topicStats: readonly TopicStat[];
}

export default function StatsBarChart({ topicStats }: StatsBarChartProps) {
  const data = topicStats.map((stat) => ({
    name: stat.displayName,
    value: stat.solvedCount,
    rate: stat.correctRate,
  }));

  return (
    <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6">
      <h2 className="text-lg font-bold mb-4">카테고리별 푼 문제</h2>
      <div className="w-full">
        <ResponsiveContainer
          width="100%"
          height={Math.max(MINIMUM_CHART_HEIGHT_PIXELS, topicStats.length * ROW_HEIGHT_PIXELS)}
        >
          <BarChart data={data} layout="vertical" margin={{ left: 10, right: 20 }}>
            <XAxis type="number" tick={{ fontSize: 11, fill: CHART_COLOR.axisTick }} />
            <YAxis
              type="category"
              dataKey="name"
              tick={{ fontSize: 11, fill: CHART_COLOR.axisLabel }}
              width={70}
            />
            <Bar dataKey="value" radius={[0, 4, 4, 0]} barSize={14}>
              {data.map((entry) => (
                <Cell key={entry.name} fill={CHART_COLOR_BY_TONE[toCorrectRateTone(entry.rate)]} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
