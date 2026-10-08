import { useState } from "react";
import { Smartphone, X } from "lucide-react";
import { useAppLinks } from "../hooks/useAppLinks";

// 닫은 기록은 이 브라우저에만 남긴다 — 서버에 저장할 만큼 중요한 상태가 아니다
const DISMISS_KEY = "passql_app_banner_dismissed";

function readDismissed(): boolean {
  try {
    return localStorage.getItem(DISMISS_KEY) === "1";
  } catch {
    // 시크릿 모드 등 저장소 접근이 막히면 매번 보여준다
    return false;
  }
}

/**
 * 앱 출시 안내 배너 (#433).
 * 관리자 설정에 스토어 링크가 하나도 없으면 렌더링하지 않는다 — 출시 전에는 보이지 않는다.
 */
export default function AppDownloadBanner() {
  const { androidUrl, iosUrl, hasAny } = useAppLinks();
  const [dismissed, setDismissed] = useState(readDismissed);

  if (!hasAny || dismissed) return null;

  const dismiss = () => {
    setDismissed(true);
    try {
      localStorage.setItem(DISMISS_KEY, "1");
    } catch {
      // 저장 실패는 무시 — 이번 화면에서만 닫힌다
    }
  };

  return (
    <section
      aria-label="passQL 앱 출시 안내"
      className="relative bg-surface-card border border-border rounded-2xl p-4 mb-4"
    >
      <button
        type="button"
        onClick={dismiss}
        aria-label="앱 안내 닫기"
        className="absolute top-3 right-3 p-1 text-text-caption hover:text-text-secondary cursor-pointer"
      >
        <X size={16} />
      </button>
      <div className="flex items-start gap-3 pr-6">
        <div className="shrink-0 w-9 h-9 rounded-xl bg-brand/10 flex items-center justify-center">
          <Smartphone size={18} className="text-brand" />
        </div>
        <div className="min-w-0">
          <p className="text-sm font-semibold text-text-primary">passQL 앱이 출시됐어요</p>
          <p className="text-xs text-text-secondary mt-0.5">
            같은 계정으로 로그인하면 학습 기록이 그대로 이어져요.
          </p>
          <div className="flex flex-wrap gap-2 mt-3">
            {androidUrl && (
              <a href={androidUrl} target="_blank" rel="noopener noreferrer" className="btn btn-primary btn-sm">
                Google Play
              </a>
            )}
            {iosUrl && (
              <a href={iosUrl} target="_blank" rel="noopener noreferrer" className="btn btn-primary btn-sm">
                App Store
              </a>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
