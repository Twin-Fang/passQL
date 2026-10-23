import type { ReactNode } from "react";
import UnlockInAppButton from "./UnlockInAppButton";

interface LockedPreviewProps {
  // 흐리게 깔 가짜 미리보기 (서버의 잠긴 내용이 아님, lockedPreviewSamples)
  readonly preview: ReactNode;
  // 가운데 한 줄 (LOCKED_PREVIEW_CAPTIONS)
  readonly caption: string;
}

/**
 * 잠긴 기능 묶음 (#578, 앱 PassqlLockedPreview 대응): 흐린 가짜 미리보기 + 가운데 한 줄 + 알약 버튼
 * 미리보기는 읽기·포커스 차단 (aria-hidden·inert), 그릴지 말지는 호출부가 shouldShowProUi 로 정함
 */
export default function LockedPreview({ preview, caption }: LockedPreviewProps) {
  return (
    <section aria-label={caption} className="locked-preview">
      <div aria-hidden="true" inert className="locked-preview-content">
        {preview}
      </div>
      <div className="locked-preview-scrim" />
      <div className="locked-preview-overlay">
        <p className="text-sm font-semibold text-text-primary text-center break-keep">{caption}</p>
        <UnlockInAppButton />
      </div>
    </section>
  );
}
