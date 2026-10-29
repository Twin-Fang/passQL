---
type: issue
id: ISS-0327
created: 2026-10-18
topics: [store-release]
symptoms: [앱 다운로드 배너 밋밋함, AppDownloadBanner, 보라색 글자 버튼, Google Play 404]
root_cause: "배너가 공식 스토어 배지·앱 아이콘 없이 글자 버튼이었고, Play 공개 페이지가 아직 404였다"
status: resolved
resolution: "[[ISS-0327-web-download-banner-store-badges-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/531"
---

# ISS-0327: 웹 앱 다운로드 배너를 공식 스토어 배지로 재디자인

GitHub #531 (원본: 이슈 본문과 댓글).

## 증상
웹 "passQL 앱이 출시됐어요" 배너(`AppDownloadBanner`)가 밋밋하다(사용자 지적). 스토어 버튼이 보라색 글자 버튼이라 어떤 스토어인지 안 보이고, 왼쪽 아이콘이 일반 휴대폰 아이콘이다. Google Play 공개 페이지는 아직 404(비공개 테스트 중, GitHub #353)라 누르면 404로 간다.

## 재현 조건
웹 홈의 앱 다운로드 배너.

## 조사 기록
- 2026-10-18: PR #533 머지, Vercel 배포.

## 근본 원인
이슈 본문의 증상 서술 그대로.
