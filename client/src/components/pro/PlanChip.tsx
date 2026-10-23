import { useState } from "react";
import AppPassGuideModal from "./AppPassGuideModal";
import { useMemberPlan } from "../../hooks/useMemberPlan";
import { FREE_PLAN_CHIP_LABEL, PRO_PLAN_CHIP_LABEL } from "../../constants/proAccessCopy";

/**
 * 등급 칩 (#578, 앱 ProPlanChipSlot 대응): 무료 FREE(누르면 앱 안내) / 프로 PRO / 결제 꺼짐·등급 모름이면 없음
 */
export default function PlanChip() {
  const { shouldShowProUi, shouldShowProBadge } = useMemberPlan();
  const [isGuideOpen, setIsGuideOpen] = useState(false);

  if (shouldShowProBadge) {
    return <span className="badge badge-sm border-0 bg-brand-light text-brand font-semibold">{PRO_PLAN_CHIP_LABEL}</span>;
  }
  if (!shouldShowProUi) return null;
  return (
    <>
      <button
        type="button"
        className="badge badge-sm border-0 bg-surface-code text-text-secondary font-semibold cursor-pointer"
        onClick={() => setIsGuideOpen(true)}
      >
        {FREE_PLAN_CHIP_LABEL}
      </button>
      {isGuideOpen && <AppPassGuideModal onClose={() => setIsGuideOpen(false)} />}
    </>
  );
}
