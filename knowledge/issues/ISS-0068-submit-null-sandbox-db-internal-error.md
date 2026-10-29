---
type: issue
id: ISS-0068
created: 2026-04-11
topics: [practice]
symptoms: [INTERNAL_SERVER_ERROR, sandbox_db_name, "sandboxDbName null", "SubmissionService.submit", SandboxPool, "오답이에요 / 정답: ?", EXECUTABLE]
root_cause: "SubmissionService.submit()이 sandboxDbName null이면 questionUuid를 DB명으로 폴백해 없는 DB에 실행 — 임시 DB 경로가 없었다"
status: resolved
resolution: "[[ISS-0068-submit-null-sandbox-db-internal-error-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/117"
---

# ISS-0068: sandboxDbName이 null인 EXECUTABLE 문제 제출 시 INTERNAL_SERVER_ERROR

GitHub #117 (원본: 이슈 본문과 리포트 댓글).

## 증상
`POST /api/questions/{questionUuid}/submit` 응답이 `{"errorCode":"INTERNAL_SERVER_ERROR","message":"서버 내부 오류가 발생했습니다"}`이고 화면에 "오답이에요 / 정답: ?"가 표시된다. 실제 채점이 이뤄지지 않는다.

## 재현 조건
`sandbox_db_name`이 null이고 `execution_mode = EXECUTABLE`인 문제(예: `35a0ec50-5726-40e5-8c43-80d6a85173c9`)에서 선택지 선택 후 제출.

## 조사 기록
- 2026-04-11: DB 확인 결과 `sandbox_db_name = NULL`, 폴백 DB(`questionUuid` 문자열)도 없음. 같은 상황에서 `QuestionExecutionService.executeChoice()`는 `SandboxPool`로 임시 DB를 만들어 정상 동작.

## 근본 원인
`SubmissionService.submit()`에 `SandboxPool`이 주입되지 않아 임시 DB 생성 경로가 없었다.
