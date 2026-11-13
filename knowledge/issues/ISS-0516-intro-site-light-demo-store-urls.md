---
type: issue
id: ISS-0516
created: 2026-11-13
topics: [store-release, design-system]
symptoms: ["소개 사이트 어두움", "prefers-color-scheme dark", "첫 화면 정적", "웹에서 바로 풀기", "스토어 웹사이트 passql.vercel.app", "개인정보처리방침 URL 옛 주소", "marketing_url.txt", "privacy_url.txt", "휘장", "예시 후기", "네이버 수집 요청 안 됨", "sqld/trend", "sqld/mock-exam", "sqld/app"]
root_cause: "소개 사이트가 기기 다크 모드를 따라가고 첫 화면이 캡처 나열이라 앱이 하는 일이 보이지 않았고, 웹 지원 중지 뒤에도 사이트 문구·스토어 주소가 옛 웹 앱(passql.vercel.app)을 가리켰다"
status: open
resolution: null
related: ["[[DEC-0310-intro-site-light-app-demo-first-screen]]", "[[DEC-0311-web-app-support-stopped-code-kept]]", "[[DEC-0312-ios-store-urls-from-intro-site]]", "[[DEC-0313-intro-site-award-badge-sample-reviews]]", "[[ISS-0508-search-visibility-site-domain-aso]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]"]
source: "_sources/issues/ISS-0516-intro-site-light-demo-store-urls.md"
---

# ISS-0516: 소개 사이트 첫 화면 개편 — 밝은 화면 고정, 앱 재생 애니메이션, 휘장·후기, 검색 안내 3장, 스토어 주소 교체

GitHub #1057 (열림, 작업중). 원본: https://github.com/Twin-Fang/passQL/issues/1057 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1057#issuecomment-6854417068

## 증상
- passql.suhsaechan.kr 이 기기 다크 모드에서 어둡게 보인다(사용자: "밝았으면 좋겠는데").
- 첫 화면이 정적이라 앱이 무엇을 해 주는지 한눈에 안 보인다(사용자: "너무 정적이야, 맛이 안 사네").
- 웹 지원을 중지했는데(#1044) 사이트에 "웹에서 바로 풀기" 버튼·문구가 남아 있다.
- App Store·Play 의 웹사이트·개인정보처리방침 주소가 passql.vercel.app 을 가리킨다(넘겨주기로 열리긴 함).

## 재현 조건
상시. 다크 모드 기기에서 소개 사이트 열기, 스토어 앱 페이지의 개발자 웹사이트·방침 링크 확인.

## 조사 기록
- 2026-11-13: 시안 A(첫 화면 플레이 데모)·B(스크롤 스토리)·C(벤토 타일) 비교 > 사용자가 A+B 합본(시안 D) 선택, 브랜드 로고·휘장·후기·개념 단계 추가 요청 ([[DEC-0310-intro-site-light-app-demo-first-screen]], [[DEC-0313-intro-site-award-badge-sample-reviews]]).
- 2026-11-13: gh-pages 브랜치 `20261113_#1057_소개사이트_gh-pages` — 84ef18da 첫 화면 개편(`site_demo.py`·`demo.css`·`demo.js`, 다크 토큰 제거, 로고 생성), 2cd1c440 검색어별 안내 3장(`sqld/trend/`·`sqld/mock-exam/`·`sqld/app/`, sitemap 14개). 시놀로지 배포 2회, 운영 200 확인.
- 2026-11-13: 휘장 잎이 모두 세로로 서던 문제 — CSS `transform`(등장 애니메이션)이 SVG `transform` 속성을 덮어씀 > 회전은 바깥 `<g>`, 애니메이션은 안쪽 `<path>` 로 분리.
- 2026-11-13: 스토어 — Play 웹사이트 저장·공개, Play 방침 URL 저장·검토 제출. App Store 웹사이트·방침은 새 버전에서만 바뀜 > `marketing_url.txt`·`privacy_url.txt` 원본(PR #1058, [[DEC-0312-ios-store-urls-from-intro-site]]).
- 2026-11-13: Search Console sitemap 재제출. 네이버 서치어드바이저 웹 페이지 수집 요청은 자동화로 확인 버튼을 눌러도 요청이 나가지 않음(네트워크 0건) — 사이트맵 등록은 유지.
- 2026-11-13: 로컬 미리보기 포트 8765 는 다른 세션(이룸 사이트)이 쓰고 있어 다른 포트 사용. 헤드리스 Chrome 은 창 폭 하한 때문에 390px 캡처가 실제 모바일 폭이 아님 > pro-launch `web viewport --preset mobile` 로 확인.

## 근본 원인
소개 사이트가 `prefers-color-scheme` 다크 토큰을 따랐고 첫 화면이 캡처·텍스트 나열 위주였다. 웹 지원 중지(#1044)가 사이트 생성기 문구와 스토어 등록값까지는 닿지 않았다.

## 남은 일
- iOS 새 버전 제출(사용자 "배포해줘" 필요): 웹사이트·방침 URL 과 #1027 의 이름·부제·키워드가 함께 반영됨
- 네이버 웹 페이지 수집 요청(새 3장)은 서치어드바이저에서 손으로
- 실제 스토어 후기가 쌓이면 `site_content.REVIEWS` 교체 검토
