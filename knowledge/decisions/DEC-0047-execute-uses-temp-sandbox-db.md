---
type: decision
id: DEC-0047
created: 2026-04-11
reviewed: null
topics: [practice, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0059-execute-sandbox-db-access-denied]]", "[[ISS-0059-execute-sandbox-db-access-denied-report]]", "[[ISS-0048-execution-mode-choice-policy-mismatch]]"]
---

# DEC-0047: `sandboxDbName`이 없는 문제의 `/execute`는 호출마다 `SandboxPool` 임시 DB를 만들어 실행하고 지운다

## 문제 정의 (Context)
`/execute`가 `sandboxDbName` null 시 `questionUuid`를 DB명으로 폴백해 `sqld_runner` 권한 밖 DB에 접근, 모든 실행 버튼이 실패했다 (GitHub #104). 이 폴백은 GitHub #88에서 실행·제출 양쪽에 통일한 정책이었다.

## 결정 (Decision)
- `sandboxDbName`이 null이면 `SandboxPool.acquire()`로 임시 DB를 얻어 `schemaDdl` + `schemaSampleData`를 적용하고 SQL을 실행한 뒤 finally에서 `release()`로 지운다. `SandboxValidator`(선택지 생성 검증)와 같은 방식.
- `questionUuid`를 DB명으로 쓰는 폴백은 `/execute`에서 제거한다.
- `sandboxDbName`이 있으면 영구 DB 직접 실행 경로를 유지한다(리포트: 현재 쓰이지 않으나 향후 성능 최적화용).

## 검토한 대안 (Alternatives)
- `questionUuid` DB명 폴백(GitHub #88): 이 결정으로 제거. 리포트는 `/execute`가 영구 DB를 전제한 것 자체가 잘못이라고 적었다.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- `sandbox_db_name` 설정 여부와 무관하게 실행 버튼이 동작한다.

**부정**
- 호출마다 semaphore 슬롯을 소비해 동시 클릭·트래픽 증가 시 `sandbox.pool.wait_seconds` 초과 실패 가능.

## 영향 범위 (Scope)
`QuestionExecutionService.executeChoice()`, `SandboxPool`. 원본은 `SubmissionService`의 같은 폴백(#88)을 바꿨는지 적지 않았다.

## 출처 (References)
- GitHub #104 이슈 본문 「예상 동작」, `## 개요` 리포트 댓글(2026-04-11)
- GitHub #88 리포트 댓글(폴백 통일)
