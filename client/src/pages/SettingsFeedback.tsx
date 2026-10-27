import { WifiOff } from "lucide-react";
import { useOnline } from "../hooks/useOnline";
import SubpageLayout from "../components/SubpageLayout";
import FeedbackForm from "../components/FeedbackForm";

/**
 * 건의사항 서브페이지 — 글만 보내는 단건 전송 폼
 * - SubpageLayout fullHeight=true: h-screen flex-col, 헤더 고정
 * - FeedbackForm: 입력 영역 하단 고정, 위 빈 공간은 flex-1
 */
export default function SettingsFeedback() {
  const isOnline = useOnline();

  return (
    <SubpageLayout title="건의사항" fullHeight>
      {/* 오프라인 배너 */}
      {!isOnline && (
        <div className="shrink-0 flex items-center gap-2 px-3.5 py-2.5 bg-semantic-warning-light border-b border-semantic-warning-border text-[10.5px] text-semantic-warning-text">
          <WifiOff size={13} className="text-semantic-warning-text shrink-0" />
          오프라인 상태예요. 연결되면 다시 시도할 수 있어요.
        </div>
      )}
      <div className="flex-1" />
      {/* 하단 고정 입력 */}
      <FeedbackForm disabled={!isOnline} />
    </SubpageLayout>
  );
}
