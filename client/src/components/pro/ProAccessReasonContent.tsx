import { Clock, Sparkles } from "lucide-react";
import UnlockInAppButton from "./UnlockInAppButton";
import { toProAccessReason, type ProAccessErrorCode } from "../../lib/proAccess";

interface ProAccessReasonContentProps {
  readonly errorCode: ProAccessErrorCode;
  // 제목 요소 id (모달 aria-labelledby 연결용)
  readonly titleId?: string;
}

/** 프로 접근 사유 본문: 아이콘 > 사유 > 다시 열리는 때 > 앱 안내 버튼 (사유 화면·사유 창 공용) */
export default function ProAccessReasonContent({ errorCode, titleId }: ProAccessReasonContentProps) {
  const reason = toProAccessReason(errorCode);
  const ReasonIcon = errorCode === "PRO_REQUIRED" ? Sparkles : Clock;
  return (
    <div className="flex flex-col items-center text-center gap-4">
      <div className="w-14 h-14 rounded-full bg-brand-light flex items-center justify-center">
        <ReasonIcon size={28} className="text-brand" aria-hidden="true" />
      </div>
      <div className="space-y-1.5">
        <p id={titleId} className="text-base font-semibold text-text-primary break-keep">
          {reason.title}
        </p>
        {reason.resetNotice && <p className="text-sm text-text-secondary break-keep">{reason.resetNotice}</p>}
      </div>
      {reason.canUnlockWithPass && <UnlockInAppButton />}
    </div>
  );
}
