---
type: completion-report
id: ISS-0059
created: 2026-04-11
topics: [practice, ops-infra]
status: resolved
resolves: "[[ISS-0059-execute-sandbox-db-access-denied]]"
related: ["[[DEC-0047-execute-uses-temp-sandbox-db]]"]
source: "https://github.com/Twin-Fang/passQL/issues/104"
---

# ISS-0059 완료 리포트: `/execute`를 `SandboxPool` 임시 DB 방식으로 전환

GitHub #104 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
`QuestionExecutionService`에 `SandboxPool` 의존 추가. `executeChoice()`는 `sandboxDbName`이 null이면 `SandboxPool.acquire()` → `schemaDdl` + `schemaSampleData` 적용 → SQL 실행 → finally에서 `release()`(임시 DB 삭제). `questionUuid`를 DB명으로 쓰던 레거시 코드 제거. `sandboxDbName`이 있으면 기존 영구 DB 경로 유지.

## 근본 원인 (확정)
`/execute`가 "미리 만들어진 영구 sandbox DB"를 전제했으나 `SandboxPool`은 일회용 임시 DB 방식이었다(리포트).

## 재발 방지
리포트 주의사항: `/execute` 호출마다 semaphore 슬롯 1개를 쓴다. 빠르게 여러 선택지를 클릭하면 `sandbox.pool.concurrency` 한도까지 점유할 수 있고, 트래픽이 늘면 `sandbox.pool.wait_seconds` 초과로 실패할 수 있다.

## 교훈
(원본에 없음, 볼트 정리) 샌드박스 실행 경로가 여러 개면(검증·실행·제출) DB 획득 방식이 같은지 확인한다.
