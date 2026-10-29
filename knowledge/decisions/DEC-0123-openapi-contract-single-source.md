---
type: decision
id: DEC-0123
created: 2026-10-16
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0264-architecture-audit-commonization-refactor]]", "[[ISS-0264-architecture-audit-commonization-refactor-report]]"]
---

# DEC-0123: 서버 `/api/**` 계약 원본은 `api-contract/openapi.json`, 웹 타입은 생성하고 테스트·CI로 강제

## 문제 정의 (Context)
API 타입을 세 스택이 각자 손으로 작성했다 (GitHub #458).

## 결정 (Decision)
- `api-contract/openapi.json`을 `/api/**` 계약 원본으로 둔다.
- 서버 `OpenApiContractTest`가 DB 없이 컨트롤러만 띄워 스펙을 만들고 파일과 비교(다르면 실패).
- 웹은 `openapi-typescript`(7.13.0 고정)로 `src/types/generated/openapi.ts`를 생성(`npm run gen:api`).
- 앱은 `error_code_contract_test`로 앱이 처리하는 오류 코드가 계약 ErrorCode 목록에 있는지 확인(Dart 모델 생성은 범위 밖).
- CI: 서버·웹·앱 CI가 `api-contract/**` 변경에도 돌고, 웹은 `gen:api` 후 차이가 없어야 통과.
- API를 바꿀 때: `cd server && ./gradlew :PQL-Web:test --tests '*OpenApiContractTest*' -PupdateApiContract` → `cd client && npm run gen:api` → 같은 커밋.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 수작업 타입 25개와 enum 8개를 생성 타입 별칭으로 교체, `@AuthMember` 오표기 수정(운영 Swagger도 함께 고쳐짐).

**부정**
- 서버와 웹 타입이 어긋난 곳이 남아 후속 정리 대상(원본 목록).

## 영향 범위 (Scope)
`api-contract/openapi.json`, 서버 `PQL-Web` 테스트, `client/src/types/generated/openapi.ts`, 앱 `error_code_contract_test.dart`, CI 3개.

## 출처 (References)
- GitHub #458 구현 보고서 (2026-10-16) 3절
