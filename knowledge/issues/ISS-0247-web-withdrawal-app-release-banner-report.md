---
type: completion-report
id: ISS-0247
created: 2026-10-08
topics: [auth-member, store-release]
status: resolved
resolves: "[[ISS-0247-web-withdrawal-app-release-banner]]"
related: ["[[DEC-0112-web-app-core-feature-parity]]"]
source: "https://github.com/Twin-Fang/passQL/issues/433"
---

# ISS-0247 완료 리포트: 웹 회원 탈퇴 추가, 스토어 링크 설정 시에만 뜨는 앱 출시 배너

GitHub #433 `## 개요` 리포트 댓글 기준 (v0.2.0, PR #434, gh-pages PR #435).

## 해결 방법
- 서버: `V0_1_9__add_store_link_settings.sql`(`store.android_url`, `store.ios_url`, 카테고리 `STORE`, 기본값 빈 문자열), `AppSettingService.getAppLinks()`(빈 값·https가 아닌 값·설정 행 없음은 null), 공개 API `GET /api/meta/app-links`, 관리자 설정 카테고리 필터에 `STORE`.
- 웹: `pages/Settings.tsx`에 회원 탈퇴 + 확인 모달, "Android/iPhone 앱 받기" 행. `components/AppDownloadBanner.tsx`(닫으면 브라우저에 기억), `hooks/useAppLinks.ts`, `pages/Home.tsx` 오늘의 문제 위 배너.
- 탈퇴 순서는 앱(`auth_provider.dart`)과 같다: `DELETE /api/members/me` 204일 때만 쿼리 캐시(`queryClient.clear()`)·토큰·Firebase 세션(`signOut(firebaseAuth)`) 정리 → 로그인 화면. 실패 시 세션 유지 + 오류 문구.
- 문서: `client/public/legal/delete-account.html`, gh-pages `delete-account.html`에 웹 탈퇴 경로 추가, `docs/FEATURE-PARITY.md`.

## 근본 원인 (확정)
이슈 본문과 같음 (기능 부재).

## 재발 방지
- 서버 삭제 성공 뒤에만 세션을 정리 — 실패했는데 로그아웃만 시키면 사용자가 탈퇴된 줄 알기 때문(원본).
- 스토어 링크는 서버에서 https만 통과 — `javascript:` 같은 링크가 웹에 나가지 않게(원본).
- 검증: `AppSettingServiceAppLinksTest` 3/3, Playwright 390px(API 가짜 응답), 운영 Flyway `0.1.9` 적용, `GET /api/meta/app-links` → `{"androidUrl":null,"iosUrl":null}`(배너 숨김).
- 주의(원본): 실제 계정으로 웹 탈퇴는 해 보지 않음(웹 Google 로그인 자동화가 막힘). Apple 로그인은 웹에 없어 iOS Apple 가입자는 웹 로그인 불가. 출시 후 관리자 > 앱 설정 > `STORE`에 https 링크를 넣으면 바로 노출.

## 교훈
(원본에 없음, 볼트 정리) 탈퇴·로그아웃 같은 파괴적 흐름은 서버 성공 응답 뒤에만 클라이언트 상태를 지운다.
