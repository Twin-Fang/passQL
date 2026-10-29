---
type: issue
id: ISS-0176
created: 2026-10-02
topics: [question-bank, practice]
symptoms: ["앱 문제 신고 없음", "/questions/{id}/report", "report/status", submissionUuid, choiceSetUuid, "신고 완료", "409 중복 신고"]
root_cause: "해당 없음 — 웹 연습 화면의 문제 신고가 앱에 없음"
status: resolved
resolution: "[[ISS-0176-app-question-flagging-feature-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/331"
---

# ISS-0176: 앱 문제 신고 기능

GitHub #331 (원본: 이슈 본문과 댓글 2개). 관련 GitHub #222, #234, 선행 GitHub #327.

## 증상
(현재 문제점) 웹 연습 화면에는 문제 신고가 있으나 앱에는 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02 서버 API: `POST /questions/{id}/report`, `GET /questions/{id}/report/status`. 제출 응답의 `submissionUuid` 연결 필요.

## 근본 원인
해당 없음 (기능 추가).
