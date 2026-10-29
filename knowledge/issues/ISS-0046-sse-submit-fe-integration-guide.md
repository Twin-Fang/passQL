---
type: issue
id: ISS-0046
created: 2026-04-10
topics: [practice, ai]
symptoms: [api-contract.test.ts, "choiceSetId 없음", "generateChoices 제거됨", EventSource, "커스텀 헤더 미지원", X-Member-UUID, ADMIN_SEED]
root_cause: "BE #69는 SSE 생성 + choiceSetId 제출로 바뀌었는데 FE는 SSE 없이 GET choiceSets[]와 selectedChoiceKey만 쓰는 구조로 리팩토링돼 있었다"
status: resolved
resolution: "[[ISS-0046-sse-submit-fe-integration-guide-report]]"
related: ["[[ISS-0042-sse-choice-generation-submit-flow]]", "[[DEC-0040-choice-response-hides-answer]]"]
source: "https://github.com/Twin-Fang/passQL/issues/78"
---

# ISS-0046: SSE 선택지 생성·제출 플로우(#69) FE 연동 가이드 — FE/BE 불일치

GitHub #78 (원본: 이슈 본문(연동 가이드)과 댓글).

## 증상
FE contract test(`api-contract.test.ts`) 기준으로 FE는 `GET /questions/{uuid}`의 `choiceSets[]`(ADMIN_SEED)를 바로 쓰고, submit body는 `{ selectedChoiceKey }`만, `generateChoices`는 `questions.ts`에서 제거된 상태였다. BE #69는 SSE로 `choiceSetId`를 받아 `{ choiceSetId, selectedChoiceKey }`로 제출하는 구조다.

## 재현 조건
BE #69 배포 후 FE 기존 코드로 제출.

## 조사 기록
- 2026-04-10: 이슈 본문이 E2E 흐름, `generateChoices`·`submitAnswer`·`SubmitResult` 변경안을 정리. `EventSource`는 커스텀 헤더(`X-Member-UUID`)를 지원하지 않으므로 `fetch` + `ReadableStream` 방식 권장. SSE 없이 기존 선택지를 쓰면 `choiceSets[0].choiceSetUuid`를 `choiceSetId`로 넘겨야 한다. SSE 타임아웃은 BE 60초.

## 근본 원인
BE와 FE가 서로 다른 방향으로 리팩토링되어 계약이 어긋났다.
