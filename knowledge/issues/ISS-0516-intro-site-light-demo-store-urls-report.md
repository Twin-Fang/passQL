---
type: completion-report
id: ISS-0516
created: 2026-11-13
topics: [store-release, design-system]
status: resolved
resolves: "[[ISS-0516-intro-site-light-demo-store-urls]]"
related: ["[[DEC-0310-intro-site-light-app-demo-first-screen]]", "[[DEC-0311-web-app-support-stopped-code-kept]]", "[[DEC-0312-ios-store-urls-from-intro-site]]", "[[DEC-0313-intro-site-award-badge-sample-reviews]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1057#issuecomment-6855829630"
---

# ISS-0516 완료 리포트: 소개 사이트 개편 배포, iOS·Android 1.123.0 심사 제출, 스토어 주소·검색 등록 정리

## 해결 방법
- 소개 사이트(gh-pages `20261113_#1057_소개사이트_gh-pages`, 84ef18da·2cd1c440)를 시놀로지에 배포: 밝은 화면 고정, 앱 재생 첫 화면, 휘장·후기, 안내 3장(`sqld/trend/`·`sqld/mock-exam/`·`sqld/app/`), sitemap 14개.
- 릴리스 PR #1060(main > deploy, 1.123.0) 자동 머지 > 서버·AI 배포 성공, iOS 심사 자동 제출(메타데이터 `marketing_url`·`privacy_url` = 소개 사이트), Android 내부 > 프로덕션 승격·검토 제출.
- Play 웹사이트 공개, Play 방침 URL 검토 제출. Search Console: passQL·이룸 sitemap 재제출, EarLocAlert 새 주소 등록 확인. 네이버: 이룸·EarLocAlert 소유 확인(보안 문자는 사용자가 입력), EarLocAlert sitemap 제출.

## 근본 원인 (확정)
소개 사이트가 기기 다크 모드를 따랐고, 웹 지원 중지(#1044)가 사이트 생성기 문구와 스토어 등록값까지 닿지 않았다. App Store 웹사이트·방침은 새 버전 제출 때만 바뀌는 항목이었다.

## 재발 방지
- App Store 주소 2개는 `app/ios/fastlane/marketing_url.txt`·`privacy_url.txt` 원본 + `siteUrls.test.ts` 일치 검사([[DEC-0312-ios-store-urls-from-intro-site]]).
- 소개 사이트 다음 작업은 `20261113_#1057_소개사이트_gh-pages` 위에서(옛 #1027 브랜치로 재배포하면 개편이 덮임).

## 교훈
- 네이버 서치어드바이저는 자동화로 누른 확인 버튼이 요청을 보내지 않고, 소유 확인은 보안 문자를 요구한다 > 사람 손이 필요한 단계로 계획하고, 사이트맵은 `robots.txt` 의 `Sitemap:` 줄로도 수집되게 둔다.
- 공유 브라우저는 다른 세션이 같은 탭을 옮기거나 멈출 수 있다 > 내 탭(`web tab new --name`)으로 작업한다.
