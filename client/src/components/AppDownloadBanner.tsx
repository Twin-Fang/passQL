import { useState } from "react";
import { X } from "lucide-react";
import { useAppLinks } from "../hooks/useAppLinks";
import { IS_GOOGLE_PLAY_PUBLIC } from "../constants/appStoreRelease";
import appIcon from "../assets/logo/app_icon.png";
import AppStoreBadgeLinks from "./AppStoreBadgeLinks";

// 닫은 기록은 이 브라우저에만 남긴다 — 서버에 저장할 만큼 중요한 상태가 아니다
const DISMISS_KEY = "passql_app_banner_dismissed";

function isBannerDismissedInStorage(): boolean {
  try {
    return localStorage.getItem(DISMISS_KEY) === "1";
  } catch {
    // 시크릿 모드 등 저장소 접근이 막히면 매번 보여준다
    return false;
  }
}

/**
 * 앱 출시 안내 배너 (#433, #531): 앱 아이콘 + 안내 문구 + 공식 스토어 배지
 * 열 수 있는 스토어 링크가 하나도 없으면 렌더링 안 함 (Play 비공개 중엔 App Store 링크 기준)
 */
export default function AppDownloadBanner() {
  const { androidUrl, iosUrl } = useAppLinks();
  const [isDismissed, setIsDismissed] = useState(isBannerDismissedInStorage);

  const googlePlayUrl = IS_GOOGLE_PLAY_PUBLIC ? androidUrl : null;
  const hasOpenableStoreLink = !!(iosUrl || googlePlayUrl);
  if (!hasOpenableStoreLink || isDismissed) return null;

  const dismiss = () => {
    setIsDismissed(true);
    try {
      localStorage.setItem(DISMISS_KEY, "1");
    } catch {
      // 저장 실패는 무시 — 이번 화면에서만 닫힌다
    }
  };

  return (
    <section aria-label="passQL 앱 출시 안내" className="app-download-banner">
      <button
        type="button"
        onClick={dismiss}
        aria-label="앱 안내 닫기"
        className="btn btn-ghost btn-sm btn-square absolute top-2 right-2 text-text-caption hover:text-text-secondary"
      >
        <X size={16} />
      </button>

      {/* 좁은 폭: 아이콘·문구 위, 배지 아래 / sm 이상: 한 줄 (배지 오른쪽) */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between sm:pr-10">
        <div className="flex items-center gap-3 min-w-0 pr-8 sm:pr-0">
          <img src={appIcon} alt="" className="app-download-banner-icon" />
          <div className="min-w-0">
            <p className="text-sm font-semibold text-text-primary">passQL 앱이 출시됐어요</p>
            <p className="text-xs text-text-secondary mt-0.5 break-keep">
              같은 계정으로 학습 기록이 이어져요.
            </p>
          </div>
        </div>
        <AppStoreBadgeLinks appStoreUrl={iosUrl} googlePlayUrl={googlePlayUrl} />
      </div>
    </section>
  );
}
