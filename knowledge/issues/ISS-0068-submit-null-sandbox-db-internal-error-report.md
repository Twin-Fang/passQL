---
type: completion-report
id: ISS-0068
created: 2026-04-11
topics: [practice]
status: resolved
resolves: "[[ISS-0068-submit-null-sandbox-db-internal-error]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/117"
---

# ISS-0068 완료 리포트: submit()에 SandboxPool 임시 DB 경로 추가

GitHub #117 리포트 댓글 기준 (2026-04-11).

## 해결 방법
`server/PQL-Domain-Submission/.../SubmissionService.java`에 `SandboxPool` 주입. EXECUTABLE 실행 분기를 `sandboxDbName` 유무로 나눴다 — 있으면 영구 sandbox DB에 직접 실행, 없으면 `SandboxPool.acquire()` → DDL 적용 → selected/correct SQL 실행 → `SandboxPool.release()`(`finally` 보장). `executeChoice()`와 같은 패턴. `PQL-Domain-Submission/build.gradle`에 `PQL-Domain-Question` 의존성이 이미 있어 의존성 변경은 없었다.

## 근본 원인 (확정)
`sandboxDbName`이 null이면 `questionUuid` 문자열을 DB명으로 폴백해 존재하지 않는 DB에 실행했다.

## 재발 방지
리포트 주의사항: `sandbox_db_name`이 null인 EXECUTABLE 문제는 `schemaDdl`·`schemaSampleData`가 정확해야 한다. 비어 있으면 빈 DB에서 실행되므로 문제 등록 시 스키마 필드 입력이 필수다.

## 교훈
(원본에 없음, 볼트 정리) 같은 실행을 하는 두 경로(미리보기 `executeChoice`와 제출 `submit`)가 따로 구현돼 있으면 한쪽 수정이 다른 쪽에 빠지기 쉽다.
