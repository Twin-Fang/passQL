---
type: decision
id: DEC-0024
created: 2026-04-08
reviewed: null
topics: [progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0021-progress-api-streak-calculator]]", "[[ISS-0021-progress-api-streak-calculator-report]]", "[[DEC-0033-readiness-replaces-progress-rate]]"]
---

# DEC-0024: 학습 진도 지표 정의 — 푼 문제는 distinct, 정답률은 문제별 마지막 시도, 스트릭은 하루 그레이스

## 문제 정의 (Context)
홈·통계 화면 공통 진도 API(`GET /api/progress`)의 지표 계산 방식을 정해야 했다 (GitHub #25).

## 결정 (Decision)
- `solvedCount`: 같은 문제를 여러 번 풀어도 distinct로 센다.
- `correctRate`: 문제별 마지막 시도 기준, 0.0~1.0 소수, 둘째 자리 반올림.
- `streakDays`: 오늘 미제출이어도 어제까지 연속이면 유지하는 "하루 그레이스". 오늘·어제 모두 없으면 0.
- 스트릭 계산은 순수 함수(`StreakCalculator`)로 분리해 단위 테스트를 쉽게 한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이슈 본문: 순수 함수 분리로 단위 테스트가 쉬워진다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`ProgressService`, `StreakCalculator`, `SubmissionRepository`, `ProgressResponse`. 이후 GitHub #52가 같은 응답에 `readiness` 블록을 추가했다(기존 필드는 유지) — [[DEC-0033-readiness-replaces-progress-rate]].

## 출처 (References)
- GitHub #25 이슈 본문 「해결 방안」·「StreakCalculator」, `## 개요` 리포트 댓글 (2026-04-08)
