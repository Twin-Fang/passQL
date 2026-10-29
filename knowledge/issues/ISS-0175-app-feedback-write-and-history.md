---
type: issue
id: ISS-0175
created: 2026-10-02
topics: [community]
symptoms: ["앱 건의사항 없음", "/feedback", "/feedback/me", "/settings/feedback", "건의 내역"]
root_cause: "해당 없음 — 웹 건의사항 작성·내역이 앱에 없음"
status: resolved
resolution: "[[ISS-0175-app-feedback-write-and-history-report]]"
related: ["[[DEC-0088-app-settings-tab-as-mypage]]"]
source: "https://github.com/Twin-Fang/passQL/issues/330"
---

# ISS-0175: 앱 건의사항 작성 및 내역 화면

GitHub #330 (원본: 이슈 본문과 댓글 2개). 관련 GitHub #229, 선행 GitHub #327.

## 증상
(현재 문제점) 웹에는 건의사항 작성과 내 건의 목록이 있으나 앱에는 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02 서버 API: `POST /feedback`, `GET /feedback/me`.

## 근본 원인
해당 없음 (기능 추가).
