---
type: decision
id: DEC-0104
created: 2026-10-07
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0229-client-errors-logged-as-error]]", "[[ISS-0229-client-errors-logged-as-error-report]]"]
---

# DEC-0104: 4xx 처리는 WARN, 처리되지 않은 예외(500)·5xx `CustomException`만 ERROR로 기록

GitHub #395 (원본: 이슈 본문 「해결 방안」과 완료 댓글).

## 문제 정의 (Context)
4xx가 전부 ERROR로 기록돼 실제 장애 로그가 묻혔다.

## 결정 (Decision)
4xx 처리기는 WARN, 처리되지 않은 예외(500)만 ERROR로 남긴다. `CustomException`은 5xx일 때만 ERROR.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 배포 직후 잘못된 요청 3건이 ERROR 0, WARN만 기록됐다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 `GlobalExceptionHandler`의 로그 레벨.

## 출처 (References)
- GitHub #395 이슈 본문, 완료 댓글(PR #407, v0.0.247)
- [[ISS-0229-client-errors-logged-as-error]]
