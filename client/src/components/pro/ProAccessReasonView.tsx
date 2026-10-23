import { Clock, Sparkles } from "lucide-react";
import UnlockInAppButton from "./UnlockInAppButton";
import { toProAccessReason, type ProAccessErrorCode } from "../../lib/proAccess";

interface ProAccessReasonViewProps {
  readonly errorCode: ProAccessErrorCode;
}

/**
 * 프로 접근 오류 사유 화면 (#578, 앱 QuestionLoadErrorView 대응): 아이콘 > 사유 > 다시 열리는 때 > 앱 안내 버튼
 * 사유 3종: 무료 하루 한도, 공정 사용 한도(버튼 없음), 프로 필요
 * 서버가 이 오류를 줬다면 결제 켜짐 > 등급 조회 없이 그대로 그림
 */
export default function ProAccessReasonView({ errorCode }: ProAccessReasonViewProps) {
  const reason = toProAccessReason(errorCode);
  const ReasonIcon = errorCode === "PRO_REQUIRED" ? Sparkles : Clock;
  return (
    <div
      role="status"
      className="bg-surface-card border border-border rounded-2xl py-10 px-6 my-6 flex flex-col items-center text-center gap-4"
    >
      <div className="w-14 h-14 rounded-full bg-brand-light flex items-center justify-center">
        <ReasonIcon size={28} className="text-brand" />
      </div>
      <div className="space-y-1.5">
        <p className="text-base font-semibold text-text-primary break-keep">{reason.title}</p>
        {reason.resetNotice && <p className="text-sm text-text-secondary break-keep">{reason.resetNotice}</p>}
      </div>
      {reason.canUnlockWithPass && <UnlockInAppButton />}
    </div>
  );
}
