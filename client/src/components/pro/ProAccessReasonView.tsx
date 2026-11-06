import ProAccessReasonContent from "./ProAccessReasonContent";
import type { ProAccessErrorCode } from "../../lib/proAccess";

interface ProAccessReasonViewProps {
  readonly errorCode: ProAccessErrorCode;
}

/**
 * 프로 접근 오류 사유 화면 (#578, 앱 QuestionLoadErrorView 대응): 아이콘 > 사유 > 다시 열리는 때 > 앱 안내 버튼
 * 사유 3종: 무료 하루 한도, 공정 사용 한도(버튼 없음), 프로 필요
 * 서버가 이 오류를 줬다면 결제 켜짐 > 등급 조회 없이 그대로 그림
 */
export default function ProAccessReasonView({ errorCode }: ProAccessReasonViewProps) {
  return (
    <div role="status" className="bg-surface-card border border-border rounded-2xl py-10 px-6 my-6">
      <ProAccessReasonContent errorCode={errorCode} />
    </div>
  );
}
