---
type: issue
id: ISS-0067
created: 2026-04-11
topics: [practice]
symptoms: ["선택지 생성 중", "무한 로딩", SSE, generate-choices, onError, "스트림 조용히 종료", "재시도 버튼 없음"]
root_cause: "fetch+ReadableStream SSE 클라이언트가 complete/error 없이 닫힌 스트림·HTTP 에러·타임아웃을 에러로 처리하지 않음"
status: resolved
resolution: "[[ISS-0067-choice-sse-error-infinite-loading-report]]"
related: ["[[ISS-0079-sse-stream-closed-after-complete]]", "[[ISS-0084-sse-stream-closed-strictmode-recurrence]]"]
source: "https://github.com/Twin-Fang/passQL/issues/115"
---

# ISS-0067: 선택지 생성 SSE에서 에러를 못 받으면 UI가 "선택지 생성 중..."으로 영구 멈춤

GitHub #115 (원본: 이슈 본문과 리포트 댓글).

## 증상
`/generate-choices` SSE 요청에서 백엔드가 에러를 내거나 스트림이 조용히 끝나면 화면이 "선택지 생성 중..." 스피너로 영구 정지한다. 에러 메시지·재시도 버튼이 없어 새로고침 외 탈출 방법이 없다.

## 재현 조건
`choiceSetPolicy=AI_ONLY` 문제 풀이(`/daily-challenge` 또는 `/questions/:id`)에서 `POST /api/questions/{questionUuid}/generate-choices`가 3회 모두 실패(`CHOICE_SET_VALIDATION_MULTIPLE_CORRECT` 등)할 때.

## 조사 기록
- 2026-04-11: 이슈 본문 — SSE는 HTTP 200으로 시작한 뒤 비동기로 에러가 나므로, `onError` 이벤트가 전달되지 않으면 프론트가 상태를 바꾸지 못한다.

## 근본 원인
프론트 SSE 클라이언트(`client/src/api/questions.ts`)에 종결 이벤트 미수신 감지와 타임아웃이 없었다.
