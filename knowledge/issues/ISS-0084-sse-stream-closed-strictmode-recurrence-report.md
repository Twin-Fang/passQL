---
type: completion-report
id: ISS-0084
created: 2026-04-12
topics: [practice]
status: resolved
resolves: "[[ISS-0084-sse-stream-closed-strictmode-recurrence]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/147"
---

# ISS-0084 완료 리포트: SSE 라인 단위 파싱 재작성, cancelled 플래그, deps 정리

GitHub #147 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `client/src/api/questions.ts`: 정규식 파싱 → 라인 단위 파싱(`line.startsWith("event:")`)으로 공백 유무와 무관하게 처리. `\r\n`·`\r`·`\n` 혼용 정규화(RFC 8895 준수라고 적음). `PARSE_ERROR` 시 `receivedTerminalEvent` 미설정 버그 수정. `complete`/`error` 수신 후 즉시 루프 중단. `abortProcessing` 플래그 제거 → `parseAndDispatch` 반환값(`shouldStop`)으로 루프 제어. 디버그 로그 추가.
- `client/src/pages/QuestionDetail.tsx`: `cancelled` 플래그로 첫 effect 콜백 무력화, deps에 `question` 추가, `activeChoiceSet`·`question?.executionMode` 제거, `needsSseGeneration`을 effect 내부 지역 변수로.

## 근본 원인 (확정)
SSE 포맷 불일치(콜론 뒤 공백)와 StrictMode 이중 실행.

## 재발 방지
리포트 주의사항: `console.debug("[SSE] ...")`는 프로덕션 배포 전 제거 또는 로그 레벨 관리 필요. `question` 전체가 deps라 background refetch로 참조가 바뀌면 effect가 재실행된다 — `staleTime: 60_000`로 막고 있으니 staleTime 변경 시 주의. 같은 증상이 재발하면 Spring SseEmitter 버전 업데이트로 포맷이 바뀌었는지 먼저 확인.

## 교훈
(원본에 없음, 볼트 정리) 서버 EventStream에는 이벤트가 보이는데 클라이언트 파서 로그가 하나도 없으면 파싱 포맷(`event:` 뒤 공백)부터 확인한다. GitHub #115 → #136 → #147로 같은 STREAM_CLOSED 증상이 세 번 이어졌다.
