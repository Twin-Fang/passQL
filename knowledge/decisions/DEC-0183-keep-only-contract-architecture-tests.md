---
type: decision
id: DEC-0183
created: 2026-10-27
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0406-delete-functional-tests-keep-contracts]]", "[[ISS-0406-delete-functional-tests-keep-contracts-report]]"]
---

# DEC-0183: 기능 테스트는 전부 삭제하고 API 계약 테스트와 아키텍처 규칙 테스트만 남긴다

## 문제 정의 (Context)
서버·앱·웹·AI에 쌓인 기능 테스트가 실제 버그를 잡는 데 의미가 적고 변경마다 유지 비용만 커진다고 판단했다 (GitHub #680 이슈 본문).

## 결정 (Decision)
사용자 결정(2026-10-27):
- 기능 테스트는 전부 삭제하고 API 계약 테스트와 아키텍처 규칙 테스트만 남긴다.
  - 서버: `ArchitectureRulesTest`, `ArchitectureRuleTest`, `OpenApiContractTest`
  - 앱: `test/architecture/*`, `error_code_contract_test.dart`, `api_contract_test.dart`
  - 웹: `designLintRules.test.ts`, `architecture.rules.test.mjs`
  - AI: `test_architecture_rules.py`, `test_layer_import_rules.py`, `test_spring_api_contract.py`
- 앞으로 새 기능은 잠금·채점처럼 틀리면 안 되는 핵심 판정만 최소한으로 테스트한다. 나머지는 실제 화면을 띄워 확인한다(리포트).
- `tools/sqld-question-harness`의 테스트는 범위 밖.

## 검토한 대안 (Alternatives)
논의 기록 없음. 계약·규칙 테스트를 남긴 이유(리포트): 기능 확인이 아니라 구조를 지키는 장치 — 계약 테스트는 서버 API 변경 시 `openapi.json`·앱 모델 미갱신을 잡고, 규칙 테스트는 하드코딩 색, 계층 위반, 직접 저장소 접근을 막는다. CI도 서버에서는 계약 테스트만 돌리고 있었다.

## 결과 (Consequences)
**긍정**
- 서버 135, 앱 123, 웹 34, AI 3개 파일 삭제로 유지 비용 감소(리포트 수치).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
4개 스택 테스트 디렉터리, CI 테스트 단계, 이후 이슈의 검증 방식(예: GitHub #683 리포트 "기능 테스트는 #680 정책에 따라 새로 쓰지 않았다").

## 출처 (References)
- GitHub #680 이슈 본문, 리포트 댓글 (PR #681)
- [[ISS-0406-delete-functional-tests-keep-contracts]]
