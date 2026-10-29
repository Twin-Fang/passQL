---
type: decision
id: DEC-0134
created: 2026-10-16
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0299-openapi-spec-accuracy-app-contract-test]]", "[[DEC-0135-app-models-checked-not-generated]]"]
---

# DEC-0134: OpenAPI 응답 스키마 필드는 전부 required, null 가능 필드는 `@Schema(nullable = true)`로 표시

## 문제 정의 (Context)
계약 스펙(`api-contract/openapi.json`)에 required·nullable 정보가 없어 웹 생성 타입이 모든 필드에 값이 있다고 믿었다 (GitHub #493).

## 결정 (Decision)
- `OpenApiSchemaContractCustomizer`가 응답 스키마의 모든 필드를 required로 표시한다. 원본 이유: 서버는 null 값도 필드로 내보낸다.
- null 가능 필드는 DTO에 `@Schema(nullable = true)`. null 가능한 객체 참조는 `oneOf [참조, null]`로 바꾼다(원본 이유: springdoc이 `$ref` 옆에 `type: null`을 붙이면 의미가 깨짐).
- 요청 스키마(`...Request`)와 Spring 기반 스키마는 건드리지 않는다.
- null 가능 판정은 웹·앱이 nullable로 선언한 필드의 합집합에서 시작해 엔티티가 not null인 값(difficulty, isActive, createdAt 등)은 해제.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 웹이 null 처리 누락을 컴파일 시점에 잡는다(이번에 4곳 발견).

**부정**
- `OpenApiContractTest`의 `@Import`에서 커스터마이저가 빠지면 테스트는 통과하면서 표시가 조용히 사라진다.
- nullable 표시는 서버 코드 전체를 검토한 값이 아니다(예: `ChoiceItem.isCorrect`는 SSE 응답에서 null).

## 영향 범위 (Scope)
`server/PQL-Web/src/main/java/com/passql/web/config/OpenApiSchemaContractCustomizer.java`, 응답 DTO, `OpenApiContractTest`, `api-contract/openapi.json`, 웹 `src/types/generated/openapi.ts`. 계약 원본·생성 방식 자체는 기존 결정 DEC-0123(GitHub #458)을 따른다.

## 출처 (References)
- GitHub #493 설계·진행 댓글 "결정 사항"(2026-10-16), 진행 방향 변경 댓글, 리포트 댓글(PR #494)
- [[ISS-0299-openapi-spec-accuracy-app-contract-test]]
