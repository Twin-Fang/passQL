---
type: completion-report
id: ISS-0067
created: 2026-04-11
topics: [practice]
status: resolved
resolves: "[[ISS-0067-choice-sse-error-infinite-loading]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/115"
---

# ISS-0067 완료 리포트: 60초 클라이언트 타임아웃, STREAM_CLOSED 탐지, 에러·재시도 UI

GitHub #115 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `client/src/api/questions.ts` `generateChoices()`: `receivedTerminalEvent` 플래그로 `complete`/`error` 수신을 추적하고, `done === true`인데 미수신·미abort면 `STREAM_CLOSED` 에러 콜백. HTTP 4xx/5xx는 `HTTP_${status}`로 즉시 `onError`(5xx만 retryable), body 없음 `NO_BODY`, JSON 파싱 실패 `PARSE_ERROR`. `AbortError`는 정상 cleanup이라 `onError`를 부르지 않는다.
- `client/src/pages/QuestionDetail.tsx`: `SSE_TIMEOUT_MS` 60초 타임아웃 → 스트림 abort + `TIMEOUT` 에러. 에러 코드별 메시지(`TIMEOUT` "선택지 생성 시간이 초과되었어요", `STREAM_CLOSED` "서버 연결이 예기치 않게 끊겼어요"). `retryable=true`일 때만 "다시 시도" 버튼(`sseRetryCount` 증가로 재연결).
- `client/src/types/api.ts`: `SseErrorEvent`(`code`, `message`, `retryable`) 등 타입 추가.

## 근본 원인 (확정)
종결 이벤트 없이 끝난 스트림과 무응답을 에러로 바꾸는 경로가 없었다.

## 재발 방지
리포트 주의사항: 60초는 AI + 샌드박스 최악 시나리오 기준이라 서버 응답이 빨라지면 줄일 수 있다. `STREAM_CLOSED`는 `abortController.signal.aborted`를 확인해 abort된 스트림과 구별한다.

## 교훈
(원본에 없음, 볼트 정리) 이 이슈가 도입한 `STREAM_CLOSED` 탐지는 이후 정상 완료에서도 오탐을 냈다 — GitHub #136, #147 참고.
