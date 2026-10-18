import { Flame } from "lucide-react";

/** 배지 문구 원본 (#523) */
export const LATEST_TREND_BADGE_LABEL = "최신 경향";

/**
 * '최신 경향' 배지: 최신 출제 경향 반영 문제·토픽 표시 (문제 지문·추천 문제·토픽 카드·경향 화면 공통)
 */
export default function LatestTrendBadge() {
  return (
    <span className="inline-flex items-center gap-1 h-6 px-2 rounded-full bg-brand-light border border-brand-border text-brand text-xs font-semibold whitespace-nowrap">
      <Flame size={12} fill="currentColor" aria-hidden="true" />
      {LATEST_TREND_BADGE_LABEL}
    </span>
  );
}
