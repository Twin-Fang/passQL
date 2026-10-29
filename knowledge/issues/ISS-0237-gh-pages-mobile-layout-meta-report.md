---
type: completion-report
id: ISS-0237
created: 2026-10-08
topics: [store-release, design-system]
status: resolved
resolves: "[[ISS-0237-gh-pages-mobile-layout-meta]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/404"
---

# ISS-0237 완료 리포트: 375 이하 1열, OG 메타·`icon/og.png`, robots·favicon·delete-account 추가

GitHub #404 완료 댓글 기준 (gh-pages PR #427). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 화면 모음 열: 375 2 → 1, 768 2 → 2, 1440 3 → 3 (가로 넘침 모두 0px).
- 스크린샷 원본의 잘린 상태바 24px 정리, 푸터 링크 묶음(모바일 2열).
- OG/Twitter 메타·`icon/og.png`(1200×630)·canonical, 주 버튼 "웹에서 바로 시작하기"(스토어는 공개 후 TODO).
- `robots.txt`, `favicon.ico`, `delete-account.html` 추가.

## 근본 원인 (확정)
원본에 적혀 있지 않다.

## 재발 방지
참고(원본): 프로젝트 페이지라 `/passQL/robots.txt`는 404는 해소되지만 크롤러는 도메인 최상위만 읽는다.

## 교훈
원본에 적혀 있지 않다.
