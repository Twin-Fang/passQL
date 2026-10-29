---
type: decision
id: DEC-0034
created: 2026-04-10
reviewed: null
topics: [home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0036-greeting-response-schema-split]]", "[[ISS-0036-greeting-response-schema-split-report]]", "[[ISS-0040-home-screen-api-integration]]"]
---

# DEC-0034: 인사말 응답은 `nickname`·`{nickname}` 템플릿·`messageType`으로 나누고, 이모지·아이콘은 프론트가 정한다

## 문제 정의 (Context)
홈 인사말 API가 닉네임·본문·이모지를 한 문자열로 내려줘 프론트가 닉네임만 스타일링하거나 아이콘·톤을 일관되게 적용할 수 없었다. 회원 조회 실패는 예외였다 (GitHub #53).

## 결정 (Decision)
- 응답 필드: `nickname`, `message`(`{nickname}` 플레이스홀더를 포함한 템플릿), `messageType`(`GENERAL` / `COUNTDOWN` / `URGENT` / `EXAM_DAY`).
- 서버는 이모지를 내려주지 않는다. 아이콘 노출 여부·종류는 프론트가 `messageType`으로 정한다.
- 회원 조회 실패·비로그인·닉네임 공백이면 예외 대신 `nickname = "회원"` + `GENERAL`. 이 경우 D-day 메시지는 쓰지 않는다 — 원본 이유: "선택한 시험"이라는 개인 컨텍스트가 성립하지 않는다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (대체된 기존 방식: 단일 `message` 문자열 + `MEMBER_NOT_FOUND` 예외.)

## 결과 (Consequences)
**긍정**
- 프론트가 `message.replace("{nickname}", nickname)`로 렌더하고 닉네임만 따로 감쌀 수 있다. `messageType`으로 상황별 UI 톤 분기 여지.

**부정**
- breaking change — 프론트 배포와 동시 진행이 필요하고, 치환 없이 렌더하면 `{nickname}`이 노출된다.

## 영향 범위 (Scope)
`GreetingResponse`, `GreetingMessageType`, `GreetingService`, `HomeControllerDocs`, 프론트 `src/pages/Home.tsx`, `src/types/api.ts`.

## 출처 (References)
- GitHub #53 이슈 본문 「해결 방안」, `## 개요` 리포트 댓글(2026-04-10), 프론트 연동 댓글(2026-04-10)
- 이슈 본문은 `GreetingContext` / `context`로 제안했고 구현 이름은 `GreetingMessageType` / `messageType`이다.
