import { useEffect } from "react";
import { createPortal } from "react-dom";
import { X } from "lucide-react";
import AppStoreBadgeLinks from "../AppStoreBadgeLinks";
import { useAppLinks } from "../../hooks/useAppLinks";
import { APP_STORE_FALLBACK_URL, IS_GOOGLE_PLAY_PUBLIC } from "../../constants/appStoreRelease";
import { APP_PASS_GUIDE_DESCRIPTION, APP_PASS_GUIDE_TITLE } from "../../constants/proAccessCopy";

interface AppPassGuideModalProps {
  readonly onClose: () => void;
}

/**
 * 앱 이용권 안내 창 (#578): 한 줄 안내 + 스토어 배지 (웹은 판매하지 않음)
 * App Store: 관리자 링크 > 없으면 고정 주소 / Google Play: 공개 전이면 "Android 출시 준비 중"
 */
export default function AppPassGuideModal({ onClose }: AppPassGuideModalProps) {
  const { androidUrl, iosUrl } = useAppLinks();
  const appStoreUrl = iosUrl ?? APP_STORE_FALLBACK_URL;
  const googlePlayUrl = IS_GOOGLE_PLAY_PUBLIC ? androidUrl : null;

  // ESC 닫기
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onClose]);

  return createPortal(
    <div className="modal-overlay" onClick={onClose}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="app-pass-guide-title"
        className="modal-card"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-3 mb-2">
          <h2 id="app-pass-guide-title" className="text-h2 text-text-primary break-keep">
            {APP_PASS_GUIDE_TITLE}
          </h2>
          <button
            type="button"
            onClick={onClose}
            className="shrink-0 flex items-center justify-center w-7 h-7 rounded-full hover:bg-surface text-text-caption transition-colors"
            aria-label="닫기"
          >
            <X size={14} />
          </button>
        </div>
        <p className="text-sm text-text-secondary leading-relaxed break-keep mb-5">{APP_PASS_GUIDE_DESCRIPTION}</p>
        <AppStoreBadgeLinks appStoreUrl={appStoreUrl} googlePlayUrl={googlePlayUrl} />
      </div>
    </div>,
    document.body,
  );
}
