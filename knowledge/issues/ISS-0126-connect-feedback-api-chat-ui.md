---
type: issue
id: ISS-0126
created: 2026-04-13
topics: [community]
symptoms: ["건의사항", useMyFeedback, "GET /feedback/me", "404 fallback", "빈 배열 fallback", SettingsFeedback]
root_cause: "백엔드 건의사항 API 미구현 기간용 404 fallback(`{ items: [] }`)이 API 구현 후에도 남아 에러를 무시함"
status: resolved
resolution: "[[ISS-0126-connect-feedback-api-chat-ui-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/229"
---

# ISS-0126: 건의사항 화면이 실제 API 대신 404 fallback으로 동작

GitHub #229 (원본: 이슈 본문과 리포트 댓글).

## 증상
건의사항 UI(`SettingsFeedback`, `FeedbackForm`, `FeedbackList`)와 API 함수(`src/api/feedback.ts`)는 있으나, `useMyFeedback` 훅이 `GET /feedback/me` 404 응답을 빈 배열(`{ items: [] }`)로 처리하는 임시 fallback을 유지하고 있었다. 백엔드 API가 구현된 뒤에도 에러를 무시하는 상태.

## 재현 조건
해당 없음 (기능 연결 작업).

## 조사 기록
- 2026-04-13: fallback 분기 제거와 실제 API 연결, 건의사항 화면 채팅 버블 UI 재설계를 함께 진행(리포트 댓글).

## 근본 원인
백엔드 미구현 기간 대응용 임시 코드가 제거되지 않았다.
