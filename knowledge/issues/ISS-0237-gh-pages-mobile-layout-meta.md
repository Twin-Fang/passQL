---
type: issue
id: ISS-0237
created: 2026-10-07
topics: [store-release, design-system]
symptoms: ["소개 페이지 gh-pages", "폭 375 스크린샷 2열", "상태바 노치 잘림", "og:image 없음", "robots.txt 404", "favicon.ico 404"]
root_cause: "원본에 적혀 있지 않다 (gh-pages `index.html`/`style.css`의 모바일 레이아웃·메타 누락)"
status: resolved
resolution: "[[ISS-0237-gh-pages-mobile-layout-meta-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/404"
---

# ISS-0237: 소개 페이지(gh-pages) 모바일 레이아웃 깨짐과 메타 누락

GitHub #404 (원본: 이슈 본문과 완료 댓글).

## 증상
- 소개 페이지(https://twin-fang.github.io/passQL/) 폭 375에서 앱 스크린샷이 2열이라 글자를 읽을 수 없음.
- 히어로 폰 이미지 상단 상태바가 노치에 가려 잘림, 푸터 "문의"가 혼자 줄바꿈.
- og:image 없음, 웹앱·스토어로 가는 링크 없음, robots.txt·favicon.ico 404.

## 재현 조건
폭 375에서 소개 페이지 열기.

## 조사 기록
- 2026-10-07: 대상 gh-pages 브랜치 `index.html`/`style.css`.

## 근본 원인
원본에 적혀 있지 않다.
