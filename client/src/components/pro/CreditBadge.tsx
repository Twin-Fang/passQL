import { Zap } from "lucide-react";
import { useMemberPlan } from "../../hooks/useMemberPlan";
import { remainingCreditsOfPlan } from "../../lib/proAccess";

/**
 * 상단 바 오늘 남은 크레딧 (#995, 앱 상단 크레딧 알약 대응): 번개 아이콘 + 숫자
 * 무료·결제 켜짐일 때만 (프로·결제 꺼짐·등급 모름이면 없음)
 */
export default function CreditBadge() {
  const { plan } = useMemberPlan();
  const remainingCredits = remainingCreditsOfPlan(plan);
  if (remainingCredits === null) return null;
  return (
    <span
      className="badge badge-sm border-0 bg-brand-light text-brand font-semibold gap-1"
      aria-label={`오늘 남은 크레딧 ${remainingCredits}개`}
      title="오늘 남은 크레딧"
    >
      <Zap size={12} aria-hidden="true" />
      {remainingCredits}
    </span>
  );
}
