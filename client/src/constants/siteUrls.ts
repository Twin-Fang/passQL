/**
 * 운영 주소 단일 원본: 웹 사이트, API, 공개 약관 (#462)
 * vite.config.ts(index.html og 태그)·api/client.ts 가 이 값을 읽음
 * vercel.json redirects·public/legal/*.html 사본은 siteUrls.test.ts 가 일치 검사
 */

// 웹 운영 주소 (Vercel, og:url·og:image 기준)
export const PRODUCTION_SITE_URL = "https://passql.vercel.app";

// 운영 API 기준 주소 (VITE_API_BASE_URL 미설정 시 기본값)
export const PRODUCTION_API_BASE_URL = "https://api.passql.suhsaechan.kr/api";

// 공개 약관 정적 페이지 (GitHub Pages, gh-pages 브랜치)
export const PUBLIC_LEGAL_SITE_URL = "https://twin-fang.github.io/passQL";

// 웹 /legal/{파일} > 공개 약관 페이지 파일 3개: 이용약관, 개인정보처리방침, 계정 삭제 안내
export const PUBLIC_LEGAL_PAGE_FILES = ["terms.html", "privacy.html", "delete-account.html"] as const;
