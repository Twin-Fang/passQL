---
type: completion-report
id: ISS-0079
created: 2026-04-11
topics: [practice]
status: resolved
resolves: "[[ISS-0079-sse-stream-closed-after-complete]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/136"
---

# ISS-0079 완료 리포트: SSE 로깅 필터 제외, effect deps 정리, abortProcessing 확인

GitHub #136 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `server/PQL-Web/src/main/resources/application.yml`: `suh-logger.exclude-patterns`에 `generate-choices` 추가(`String.contains()` 기반이라 Ant 패턴 불필요).
- `client/src/pages/QuestionDetail.tsx`: SSE effect deps에서 `needsSseGeneration`(및 `sseChoices`, `sseError`) 제거, deps는 `[questionUuid, sseRetryCount, question]`. 필요 여부는 effect 본문 첫 줄에서 확인.
- `client/src/api/questions.ts`: `done: true` 분기 조건을 `!receivedTerminalEvent && !abortProcessing && !abortController.signal.aborted`로.

## 근본 원인 (확정)
로깅 필터의 SSE 버퍼링, exclude 패턴 매칭 방식 오해, effect deps race, `abortProcessing` 미확인 — 네 가지가 겹쳤다.

## 재발 방지
리포트 주의사항: SSE 엔드포인트를 추가하면 `suh-logger.exclude-patterns`에 suffix 문자열로 등록할 것. SSE effect deps에 스트림 결과 상태(`sseChoices`, `sseError`)를 넣으면 같은 race가 재발한다.

## 교훈
(원본에 없음, 볼트 정리) 서버는 정상 완료 로그인데 브라우저 EventStream이 비어 있으면 응답을 감싸는 필터(로깅·캐싱)부터 의심한다. 같은 증상이 다음 날 GitHub #147로 재발했다.
