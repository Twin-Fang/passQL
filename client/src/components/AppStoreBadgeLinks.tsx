// 공식 스토어 배지 (변형 금지: 비율·색 그대로, 높이만 맞춤) (#531)
// App Store: Apple Marketing Tools 한국어 black SVG (toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/ko-kr)
// Google Play: 공식 배지 한국어 PNG (play.google.com/intl/en_us/badges/static/images/badges/ko_badge_web_generic.png, 위아래 투명 여백 포함)
import appStoreBadge from "../assets/store-badges/app_store_download_badge_ko_black.svg";
import googlePlayBadge from "../assets/store-badges/google_play_badge_ko.png";

interface AppStoreBadgeLinksProps {
  readonly appStoreUrl: string | null;
  // null > "Android 출시 준비 중" 비활성 표시 (Play 비공개 또는 링크 미설정)
  readonly googlePlayUrl: string | null;
}

/**
 * 스토어 배지 2개 나란히: App Store, Google Play(또는 출시 준비 중)
 * 배지 높이는 components.css .store-badge-group 의 --store-badge-height 하나로 통일
 */
export default function AppStoreBadgeLinks({ appStoreUrl, googlePlayUrl }: AppStoreBadgeLinksProps) {
  return (
    <div className="store-badge-group">
      {appStoreUrl && (
        <a href={appStoreUrl} target="_blank" rel="noopener noreferrer" className="store-badge-link">
          <img src={appStoreBadge} alt="App Store에서 다운로드하기" className="store-badge-app-store" />
        </a>
      )}
      {googlePlayUrl ? (
        <a href={googlePlayUrl} target="_blank" rel="noopener noreferrer" className="store-badge-link">
          <img src={googlePlayBadge} alt="Google Play에서 다운로드" className="store-badge-google-play" />
        </a>
      ) : (
        // 배지와 같은 높이·2줄 구성, 링크 아님 > 클릭 불가
        <span role="img" aria-label="Android 출시 준비 중" className="store-badge-coming-soon">
          <span className="text-micro leading-none">Android</span>
          <span className="text-xs font-semibold leading-tight">출시 준비 중</span>
        </span>
      )}
    </div>
  );
}
