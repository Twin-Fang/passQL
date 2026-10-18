import { Link } from "react-router-dom";
import { ChevronRight, Flame } from "lucide-react";
import LatestTrendBadge from "../LatestTrendBadge";

interface ExamTrendEntryCardProps {
  readonly className?: string;
}

/**
 * 홈 출제 경향 진입 카드 (#523): 서버 호출 없음, 클릭 > /exam-trend
 */
export default function ExamTrendEntryCard({ className = "" }: ExamTrendEntryCardProps) {
  return (
    <Link to="/exam-trend" className={`block mb-4 ${className}`}>
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-5 flex items-center gap-3 cursor-pointer hover:-translate-y-0.5 hover:border-brand transition-all duration-200">
        <div className="w-10 h-10 rounded-xl bg-brand-light flex items-center justify-center shrink-0">
          <Flame size={20} fill="currentColor" className="text-brand" aria-hidden="true" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <p className="text-sm font-semibold text-text-primary">2026 SQLD 출제 경향</p>
            <LatestTrendBadge />
          </div>
          <p className="text-xs text-text-secondary mt-1">최근 시험에서 늘어난 유형과 최신 경향 문제를 모았어요</p>
        </div>
        <ChevronRight size={16} className="text-text-caption shrink-0" aria-hidden="true" />
      </div>
    </Link>
  );
}
