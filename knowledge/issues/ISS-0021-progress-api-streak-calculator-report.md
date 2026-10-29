---
type: completion-report
id: ISS-0021
created: 2026-04-08
topics: [progress-stats]
status: resolved
resolves: "[[ISS-0021-progress-api-streak-calculator]]"
related: ["[[DEC-0024-progress-metric-definitions]]"]
source: "https://github.com/Twin-Fang/passQL/issues/25"
---

# ISS-0021 완료 리포트: `StreakCalculator` 순수 함수 분리, 회원 존재 404 검증

GitHub #25 `## 개요` 리포트 댓글(2026-04-08) 기준.

## 해결 방법
- `PQL-Domain-Submission/.../util/StreakCalculator.java` 신규: static 순수 함수, `final` + private 생성자, 하루 그레이스 포함. `ProgressService`의 private `calculateStreak()`를 대체.
- `ProgressService.getProgress()`: `existsByMemberUuidAndIsDeletedFalse`로 회원 검증 → 없으면 `MEMBER_NOT_FOUND`(404).
- `correctRate`: `calculateCorrectRateByMemberUuid` native query(`ROW_NUMBER() OVER PARTITION BY question_uuid ORDER BY submitted_at DESC`)로 문제별 마지막 제출만 집계, `Math.round(rateRaw * 100.0) / 100.0`.
- `solvedCount`: `COUNT(DISTINCT question_uuid)`.
- `PQL-Domain-Submission/build.gradle`에 `api project(':PQL-Domain-Member')`.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 주의사항: `PQL-Domain-Submission` → `PQL-Domain-Member` 직접 의존이 생겼다 — 결합이 늘면 `PQL-Application`에서 Member 검증을 맡도록 리팩토링 고려. `findSubmissionDatesByMemberUuid`의 `FUNCTION('DATE', ...)` JPQL은 MySQL/MariaDB 전용이라 H2 `@DataJpaTest`에서 실패한다.

## 교훈
원본에 적혀 있지 않다.
