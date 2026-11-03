---
type: decision
id: DEC-0237
created: 2026-11-03
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0441-third-audit-remaining-items]]", "[[ISS-0441-third-audit-remaining-items-report]]", "[[DEC-0236-block-raw-exception-message-at-handler]]"]
---

# DEC-0237: 요청 본문은 검증 붙은 요청 DTO 로 받는다 (키가 자유로운 맵만 예외)

## 맥락
공개·관리자 API 10곳이 `@RequestBody Map` 으로 받아 OpenAPI 계약이 `additionalProperties` 가 되고, 키가 없으면 NPE·ClassCastException 500 이 났다 (GitHub #791).

## 결정
- 요청 본문은 엔드포인트별 `...Request` record + jakarta 검증(`@NotNull`·`@NotBlank` 등) + `@Valid` 로 받는다. 실패는 기존 처리기의 `VALIDATION_ERROR`(400).
- JSON 필드 이름은 기존 호출부와 같게 둔다 (와이어 형식 유지).
- 예외: 키 이름이 데이터마다 달라지는 맵(관리자 프롬프트 테스트 `variables`)은 `Map` 을 유지한다.

## 대안
- `Map` 유지 + 컨트롤러에서 키 검사: 계약에 형태가 안 드러나고 검사 코드가 엔드포인트마다 복사되어 버림.

## 결과
- 공개 API 3곳 오류 코드가 `VALIDATION_ERROR`·`MESSAGE_NOT_READABLE` 로 바뀜 (상태 400 그대로).
- 관리자 API 는 키 누락 시 false·null 저장 대신 400.

## 영향 범위
서버 컨트롤러·요청 DTO, `api-contract/openapi.json`, 웹 생성 타입.
