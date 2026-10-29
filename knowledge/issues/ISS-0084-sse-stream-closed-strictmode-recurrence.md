---
type: issue
id: ISS-0084
created: 2026-04-12
topics: [practice]
symptoms: [STREAM_CLOSED, "서버 연결이 예기치 않게 끊겼어요", "SSE complete", StrictMode, "done: true 즉시", "event:complete", SseEmitter, "이벤트 파싱 실패", "재발"]
root_cause: "Spring SseEmitter는 'event:name'(콜론 뒤 공백 없음)으로 보내는데 프론트 정규식이 'event: name'만 처리해 이벤트를 버렸고, StrictMode 이중 실행이 두 번째 SSE 요청을 보냈다"
status: resolved
resolution: "[[ISS-0084-sse-stream-closed-strictmode-recurrence-report]]"
related: ["[[ISS-0079-sse-stream-closed-after-complete]]", "[[ISS-0067-choice-sse-error-infinite-loading]]"]
source: "https://github.com/Twin-Fang/passQL/issues/147"
---

# ISS-0084: SSE complete 수신 후 STREAM_CLOSED 재발 (StrictMode cancelled 패턴 미동작)

GitHub #147 (원본: 이슈 본문과 리포트 댓글).

## 증상
원본 표기 `#039` 이슈에서 고쳤던 SSE STREAM_CLOSED 버그가 재발. 서버는 `complete`를 보내고 200으로 끝났고 DevTools EventStream에도 `status → validating → complete`가 보이는데, 콘솔에는 `[SSE] read`·`processBuffer`·`complete 수신` 없이 `[SSE] STREAM_CLOSED: complete/error 없이 스트림 종료`만 찍힌다.

## 재현 조건
로컬(`localhost:5174` → `localhost:8080`), React 19 StrictMode, 선택지가 없는 문제(`choiceSets: []`) 진입.

## 조사 기록
- 2026-04-12: 이슈 본문 가설 — StrictMode가 effect를 mount → cleanup → re-mount로 두 번 돌려 두 번째 SSE 요청이 이미 처리된 스트림에서 `done: true`를 즉시 받는다.
- 2026-04-12: 리포트 — 실제 근본 원인은 두 가지(아래).

## 근본 원인
(1) `SseEmitter.event().name("complete")`는 `event:complete`(공백 없음)로 직렬화되는데 기존 정규식 `/^event: (\w+)/m`은 공백을 요구해 이벤트 전체가 무시됐다. (2) StrictMode 이중 실행 대비가 없어 두 번째 effect가 같은 엔드포인트로 재요청했다.
