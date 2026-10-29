---
type: issue
id: ISS-0406
created: 2026-10-27
topics: [dev-workflow]
symptoms: ["기능 테스트 유지 비용", "테스트 삭제", OpenApiContractTest, ArchitectureRulesTest, "테스트 0개 단계"]
root_cause: "기능 테스트가 많이 쌓였지만 실제 버그를 잡는 의미가 적고 변경마다 유지 비용만 커졌다 (이슈 본문 판단)"
status: resolved
resolution: "[[ISS-0406-delete-functional-tests-keep-contracts-report]]"
related: ["[[DEC-0183-keep-only-contract-architecture-tests]]"]
source: "https://github.com/Twin-Fang/passQL/issues/680"
---

# ISS-0406: 기능 테스트 삭제, 계약·아키텍처 규칙 테스트만 유지

GitHub #680 (원본: 이슈 본문과 댓글).

## 증상
서버·앱·웹·AI에 기능 테스트가 많이 쌓여 있지만 실제 버그를 잡는 데 의미가 적고 변경할 때마다 유지 비용만 커지고 있다(이슈 본문).

## 재현 조건
해당 없음 (정책 변경 이슈).

## 조사 기록
- 2026-10-27: 사용자 결정 — 기능 테스트 전부 삭제, API 계약·아키텍처 규칙 테스트만 유지.
- 범위 제외: 문제 검증 도구 `tools/sqld-question-harness`의 테스트.

## 근본 원인
원본에 적혀 있지 않다 (이슈 본문의 비용 판단만 있음).
