/**
 * 배포 직후 옛 번들 복구 (#881): 지워진 화면 청크 로드 실패(vite:preloadError) > 새 index.html 받도록 1회 새로고침
 * 반복 방지: 방금 새로고침으로 열린 페이지에서 또 실패하면 새로고침하지 않고 오류 화면(RouteError)에 맡김
 */

// 새로고침 직후로 보는 기간 (이 안에서 또 실패하면 배포 문제가 아니라 다른 원인)
const RECENT_RELOAD_WINDOW_MILLISECONDS = 10_000;
const VITE_PRELOAD_ERROR_EVENT = "vite:preloadError";

/** 이 페이지가 방금 새로고침으로 열렸는지 (자동·수동 공통) */
function isRecentlyReloadedPage(): boolean {
  const [navigationEntry] = performance.getEntriesByType("navigation") as PerformanceNavigationTiming[];
  return navigationEntry?.type === "reload" && performance.now() < RECENT_RELOAD_WINDOW_MILLISECONDS;
}

/** 청크 로드 실패 감시 시작 (앱 진입점 1회) */
export function installStaleBundleReload(): void {
  window.addEventListener(VITE_PRELOAD_ERROR_EVENT, (event) => {
    if (isRecentlyReloadedPage()) return;
    // 기본 동작(throw) 막고 새로고침 > 새 해시 번들로 같은 주소 다시 열기
    event.preventDefault();
    window.location.reload();
  });
}
