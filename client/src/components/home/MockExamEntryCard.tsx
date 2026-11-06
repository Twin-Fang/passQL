import { Link } from "react-router-dom";
import { ChevronRight, ClipboardCheck } from "lucide-react";
import { MOCK_EXAM_ROUNDS_PATH } from "../../constants/mockExamRoutes";
import { MOCK_EXAM_ENTRY_DESCRIPTION, MOCK_EXAM_TITLE } from "../../constants/mockExamCopy";

interface MockExamEntryCardProps {
  readonly className?: string;
}

/**
 * 홈 SQLD 모의고사 진입 카드 (#866): 서버 호출 없음, 클릭 > 회차 목록 (문제 수 노출 없음, #636)
 */
export default function MockExamEntryCard({ className = "" }: MockExamEntryCardProps) {
  return (
    <Link to={MOCK_EXAM_ROUNDS_PATH} className={`block mb-4 ${className}`}>
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-5 flex items-center gap-3 cursor-pointer hover:-translate-y-0.5 hover:border-brand transition-all duration-200">
        <div className="w-10 h-10 rounded-xl bg-brand-light flex items-center justify-center shrink-0">
          <ClipboardCheck size={20} className="text-brand" aria-hidden="true" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold text-text-primary">{MOCK_EXAM_TITLE}</p>
          <p className="text-xs text-text-secondary mt-1">{MOCK_EXAM_ENTRY_DESCRIPTION}</p>
        </div>
        <ChevronRight size={16} className="text-text-caption shrink-0" aria-hidden="true" />
      </div>
    </Link>
  );
}
