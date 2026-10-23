/**
 * 앱 스토어 공개 상태 단일 원본 (#531)
 * 스토어 링크 주소는 관리자 설정(/meta/app-links)이 원본 > 여기엔 공개 여부만
 */

// Google Play 공개 여부: 비공개 테스트 중이라 공개 페이지 404 (#353)
// false > 웹 배너에 Play 배지 대신 "Android 출시 준비 중"(클릭 불가) 표시. 공개되면 true 로 변경
export const IS_GOOGLE_PLAY_PUBLIC = false;

// App Store 앱 페이지: 관리자 링크(/meta/app-links)를 못 받았을 때만 쓰는 고정 주소 (이용권 안내 창, #578)
export const APP_STORE_FALLBACK_URL = "https://apps.apple.com/kr/app/id6762165005";
