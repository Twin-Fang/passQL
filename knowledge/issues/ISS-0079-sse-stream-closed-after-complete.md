---
type: issue
id: ISS-0079
created: 2026-04-11
topics: [practice]
symptoms: [STREAM_CLOSED, "서버 연결이 예기치 않게 끊겼어요", "SSE complete", SuhLoggingFilter, ContentCachingResponseWrapper, exclude-patterns, needsSseGeneration, abortProcessing]
root_cause: "SuhLoggingFilter가 SSE 응답을 버퍼링했고(exclude 패턴은 String.contains 기반이라 매칭 실패), effect deps의 needsSseGeneration이 complete 후 스트림을 abort했다"
status: resolved
resolution: "[[ISS-0079-sse-stream-closed-after-complete-report]]"
related: ["[[ISS-0067-choice-sse-error-infinite-loading]]", "[[ISS-0084-sse-stream-closed-strictmode-recurrence]]"]
source: "https://github.com/Twin-Fang/passQL/issues/136"
---

# ISS-0079: SSE complete 이벤트를 받은 뒤에도 STREAM_CLOSED 에러가 트리거

GitHub #136 (원본: 이슈 본문, 본문 끝 해결 메모, 리포트 댓글).

## 증상
선택지 생성 SSE에서 서버 로그는 `SSE complete 전송: ... itemCount=4`로 정상인데 화면에 "서버 연결이 예기치 않게 끊겼어요"가 표시된다.

## 재현 조건
선택지가 없는 문제(`CONCEPT_ONLY` 또는 `EXECUTABLE`) 상세 진입 → `generate-choices` SSE 자동 발화 → 서버가 `complete` 전송. Android Chrome 146.

## 조사 기록
- 2026-04-11: 이슈 본문 끝 메모 — `done` 블록에 `!abortProcessing` 조건 추가. `PARSE_ERROR` 시 `abortProcessing=true`인데 `done` 블록이 확인하지 않아 `STREAM_CLOSED`가 함께 나갔다.
- 2026-04-11: 리포트 댓글이 원인 세 가지와 부수 원인 하나로 정리(아래).

## 근본 원인
(1) `suh-logger`의 `SuhLoggingFilter`가 응답을 `ContentCachingResponseWrapper`로 감싸 SSE를 끝날 때까지 버퍼링. (2) `exclude-patterns`가 Ant 패턴이 아니라 `String.contains()` 기반이라 `**/generate-choices`가 매칭 실패. (3) `needsSseGeneration`이 effect deps에 있어 `onComplete` → 리렌더 → cleanup → `abortController.abort()` race. (부수) `abortProcessing` 미확인.
