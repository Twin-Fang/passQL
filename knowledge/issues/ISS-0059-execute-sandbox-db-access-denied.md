---
type: issue
id: ISS-0059
created: 2026-04-11
topics: [practice, ops-infra]
symptoms: ["Access denied for user 'sqld_runner'", "1044-42000", "sandboxDbName null", "/execute", "실행 버튼 동작 안 함", SQLSyntaxErrorException, "questionUuid DB명"]
root_cause: "/execute가 sandboxDbName null이면 questionUuid를 DB명으로 쓰는 레거시 폴백을 썼는데 sqld_runner는 sandbox_xxxxx DB에만 권한이 있다. 리포트: /execute가 영구 sandbox DB를 전제했지만 SandboxPool은 일회용 임시 DB 방식이었다"
status: resolved
resolution: "[[ISS-0059-execute-sandbox-db-access-denied-report]]"
related: ["[[DEC-0047-execute-uses-temp-sandbox-db]]", "[[ISS-0048-execution-mode-choice-policy-mismatch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/104"
---

# ISS-0059: `/execute`가 `questionUuid`를 DB명으로 폴백해 Access Denied — 모든 문제의 실행 버튼 불능

GitHub #104 (원본: 이슈 본문과 댓글).

## 증상
선택지 "실행" 버튼 → `/api/questions/{questionUuid}/execute` → `Access denied for user 'sqld_runner'@'localhost' to database '35a0ec50-5726-40e5-8c43-80d6a85173c9'`(`Error: 1044-42000`, 응답 `errorCode: SQLSyntaxErrorException`). 등록된 모든 문제의 `sandbox_db_name`이 null이라 사실상 모든 실행 버튼이 동작하지 않는다.

## 재현 조건
`sandbox_db_name`이 null인 EXECUTABLE 문제에서 선택지 실행 버튼 클릭.

## 조사 기록
- 2026-04-11: 리포트 댓글로 수정. 이 폴백은 GitHub #88에서 `QuestionExecutionService`·`SubmissionService` 양쪽에 통일한 정책이다.

## 근본 원인
잘못된 레거시 폴백과, `/execute`가 영구 DB를 전제한 설계.
