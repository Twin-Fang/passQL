---
type: issue
id: ISS-0191
created: 2026-10-06
topics: [store-release]
symptoms: [개인정보 처리방침 공개 URL 없음, 이용약관 공개 URL 없음, 스토어 메타데이터 미정리, "/legal/privacy.html"]
root_cause: "약관·개인정보처리방침이 앱 안과 서버 API에만 있고 공개 URL이 없었다"
status: resolved
resolution: "[[ISS-0191-store-public-legal-pages-metadata-report]]"
related: ["[[ISS-0192-play-closed-test-and-ios-review-submit]]", "[[ISS-0204-github-pages-intro-legal-site]]"]
source: "https://github.com/Twin-Fang/passQL/issues/346"
---

# ISS-0191: 스토어 등록용 공개 약관 페이지와 심사 제출 정보 정리

GitHub #346 (원본: 이슈 본문과 댓글).

## 증상
App Store Connect·Play Console 등록에는 공개 웹 주소의 개인정보 처리방침과 이용약관이 필요한데, 앱 안과 서버 API에만 있고 공개 URL이 없다. 심사 제출용 메타데이터(설명, 키워드, 심사 메모, 연령 등급, 개인정보 설문)도 정리되어 있지 않다.

## 재현 조건
해당 없음 (스토어 등록 준비).

## 조사 기록
- 2026-10-06: 계획 — 서버 약관·방침으로 정적 공개 페이지를 웹(Vercel)에 올린다: `/legal/privacy.html`, `/legal/terms.html`.
- 2026-10-07: 진행 기록은 GitHub #347과 같은 댓글(Play·App Store Connect 진행 현황)로 남김.

## 근본 원인
공개 URL과 등록 정보가 준비되지 않은 상태였다.
