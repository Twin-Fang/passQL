---
type: decision
id: DEC-0200
created: 2026-10-28
reviewed: null
topics: [practice, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0421-surface-direct-sql-execution]]", "[[ISS-0421-surface-direct-sql-execution-report]]"]
---

# DEC-0200: 샌드박스 실행 결과는 `CachedSandboxExecutor` 한 곳에서 회원 간 공유 캐시(메모리 30분 > Redis 7일)로 재사용한다

## 문제 정의 (Context)
보기·실습 실행이 늘면 시놀로지 샌드박스 부하가 커진다. 실행형 문제는 답안 제출마다 2회 실행하고 있었다 (GitHub #727 2차 변경 댓글·리포트).

## 결정 (Decision)
- 같은 문제·같은 SQL 결과를 회원 간 공유. 서버 메모리(Caffeine 30분, 5천 건) > Redis(7일, blue·green 공유) 순 조회, 없을 때만 실행.
- 보기·실습 실행, 답안 제출, AI 해설 근거 수집이 모두 이 한 곳을 거친다.
- 키 = 문제 UUID + sha256(영구 DB 이름·DDL·샘플·수정 시각·정리한 SQL) — 문제를 고치면 자동 무효.
- 저장 대상: SELECT·WITH 성공(1천 행 이하)과 늘 같은 SQL 오류. 시간 초과·연결 오류는 저장 안 함.
- 캐시 결과도 원래 실행 시간(ms)을 그대로 보여 주고, 앱은 실행 중 표시를 최소 0.45초 유지.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 운영 로그: 답안 제출 4641ms → 97ms, 보기 실행 7605ms → 29ms.

**부정**
- 영구 샌드박스 DB 데이터를 문제 수정 없이 직접 바꾸면 최대 7일 옛 결과.
- 해설 근거 수집도 영구 DB 우선 경로가 되어, 영구 DB와 DDL이 어긋난 문제는 해설 근거도 영구 DB 기준.
- 쓰기 SQL 저장 조건을 풀면 상태를 바꾸는 SQL 결과가 공유될 위험.

## 영향 범위 (Scope)
`CachedSandboxExecutor`(PQL-Domain-Question), `QuestionExecutionService`, `SubmissionService`, `ChoiceSetExecutionEvidenceCollector`, Redis 키 `sandbox:result:v1:*`.

## 출처 (References)
- GitHub #727 2차 변경 댓글, 리포트 댓글 (2026-10-28)
- [[ISS-0421-surface-direct-sql-execution]]
