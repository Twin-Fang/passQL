---
type: completion-report
id: ISS-0421
created: 2026-10-28
topics: [practice]
status: resolved
resolves: "[[ISS-0421-surface-direct-sql-execution]]"
related: ["[[DEC-0199-choice-execution-only-after-submit]]", "[[DEC-0200-shared-sandbox-result-cache]]"]
source: "https://github.com/Twin-Fang/passQL/issues/727"
---

# ISS-0421 완료 리포트: 제출 뒤 보기 실행, 결과 비교 카드, 실습 칸, 입력 보조 막대, 샌드박스 공유 캐시

GitHub #727 리포트 댓글 기준 (PR #737, 배포 #738, v1.68.x). 코드 점검 반영 PR #743(동작 변경 없음).

## 해결 방법
- 앱: 보기 실행은 제출 뒤에만(제출 전 안내 문구, 제출 뒤 ▶ — `PassqlChoiceCard.trailingAccessory`). `selectChoice`(고르기)와 `runChoice`(실행) 분리, `executedChoiceKey`.
- `ExecutionComparisonCard`: 채점 응답의 `selectedResult`·`correctResult`로 추가 호출 없이 오류 > 열 > 행 수 > 값 > 순서 순 첫 차이 요약, 상대에 없는 행 빨강·초록(`ExecuteResultComparison`, 순서 무시 다중집합 비교).
- `SqlPracticeCard`(정답에서·내 답에서·빈 칸 시작, `sqlPracticeProvider`), 고치기 시트, `SqlInputAssistBar`(커서 이동, 짝 입력 기호, SQLD 키워드, 문제의 표·열 이름과 집계 함수, 키보드 `visiblePassword`, 자동 고침·둥근 따옴표 끔).
- 결과 카드 "실제 DB 실행 · N행 반환 · Nms", 실행 중 표시 최소 0.45초.
- 서버: `CachedSandboxExecutor`(PQL-Domain-Question) — Caffeine 30분·5천 건 > Redis 7일 > 실행 후 저장. 보기·실습 실행(`QuestionExecutionService`), 답안 제출(`SubmissionService`), AI 해설 근거 수집(`ChoiceSetExecutionEvidenceCollector`)이 모두 경유. 키 `sandbox:result:v1:{questionUuid}:{sha256(영구 DB 이름·DDL·샘플·수정 시각·정리한 SQL)}`. 저장 대상 SELECT·WITH 성공(1천 행 이하)과 늘 같은 SQL 오류.
- 배포 후 실측(운영 로그): 답안 제출 4641ms → 97ms, 보기 실행 7605ms → 29ms.

## 근본 원인 (확정)
실행을 드러내는 UI와 실습 칸 부재.

## 재발 방지
- 캐시 키에 수정 시각 포함 — 영구 샌드박스 DB 데이터를 문제 수정 없이 직접 바꾸면 최대 7일(메모리 30분) 옛 결과. 그럴 땐 `sandbox:result:v1:{questionUuid}:*` 키를 지우거나 문제를 한 번 저장.
- 쓰기 SQL은 저장하지 않는다(제출 경로는 안전 검사 없이 보기 SQL을 실행 — 기존 동작). 이 조건을 풀면 상태를 바꾸는 SQL 결과가 공유될 수 있다.
- 해설 근거 수집도 영구 DB 우선 경로로 바뀜(예전에는 항상 임시 DB).
- 제출 전 실행 금지는 의도된 제한.
- Xcode 27.1 iOS 빌드 문제: CI가 Xcode 27로 오르면 같은 수정 필요.
- 범위 밖: 개념형 Oracle 문제 실행 기록 노출(구상안 E).

## 교훈
(원본에 없음, 볼트 정리) 결과를 묻는 문제에서 실행 기능을 제출 전에 열면 답이 노출된다 — 실행 노출 시점을 채점 흐름과 함께 설계한다.
