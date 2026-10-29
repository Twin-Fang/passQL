---
type: decision
id: DEC-0033
created: 2026-04-10
reviewed: null
topics: [progress-stats, home]
status: superseded
supersedes: null
superseded_by: DEC-0078
related: ["[[ISS-0035-replace-progress-with-readiness]]", "[[ISS-0035-replace-progress-with-readiness-report]]", "[[DEC-0024-progress-metric-definitions]]", "[[DEC-0078-readiness-multiplicative-core-with-bonus]]"]
---

# DEC-0033: 홈 지표를 진도율 대신 합격 준비도 `Readiness = Accuracy × Coverage × Recency`로

## 문제 정의 (Context)
무제한 문제 환경에서는 진도율이 성립하지 않는데, 홈이 `correctRate`를 progress 바로 그려 진도율로 오독됐다. 사용자가 알고 싶은 것은 합격 가능성이다 (GitHub #52).

## 결정 (Decision)
- "진도율" 개념을 버리고 합격 준비도(Readiness)로 대체한다.
- 산식: `Readiness = Accuracy × Coverage × Recency` (3요소 곱셈, 가중치 없음).
  - Accuracy: 최근 50시도의 정답률.
  - Coverage: 최근 14일 내 1회 이상 푼 활성 토픽의 비율.
  - Recency: 마지막 학습일 기반 감쇠 — 0~1일 1.0 / 2~3일 0.95 / 4~7일 0.85 / 8~14일 0.75 / 15일+ 0.70.
- 정직 모드: 초반 5%, 10% 같은 낮은 수치도 그대로 노출한다.
- 투명성: 3요소 원본값과 분모/분자(`coveredTopicCount`, `activeTopicCount`, `recentAttemptCount`)를 응답에 포함한다.
- D-day 기반 카피 톤: 백엔드가 `toneKey`(`NO_EXAM` / `ONBOARDING` / `POST_EXAM` / `TODAY` / `SPRINT(1~6일)` / `PUSH(7~14일)` / `STEADY(15~30일)` / `EARLY(31일+)`)를 내려주고 FE가 카피를 매핑한다.
- 기존 필드(`solvedCount`, `correctRate`, `streakDays`)는 100% 유지하고 `readiness` 블록을 추가만 한다. KST 기준 Recency/D-day 계산.

## 검토한 대안 (Alternatives)
- 진도율(전체 중 완료 비율): 무제한 문제 환경에서 성립하지 않아 버림.
- 토픽 가중치: 이슈 본문은 "토픽이 동적으로 추가/수정되므로 가중치 대신 커버리지로 편식 방지"라고 적었다.
- 3요소에 가중치를 두는 방식: "가중치 없음"으로 정했다. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 무한 문제 환경에서도 0~100% 게이지가 자연스럽게 성립 (이슈 본문).
- 정직 모드는 passQL의 "실제 Oracle 실행" 브랜드 철학과 일관된다고 적었다.
- 기존 FE 동작 무영향 (필드 추가만).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
백엔드 `ReadinessConstants`, `ReadinessCalculator`, `ToneKeyResolver`, `ReadinessResponse`, `ProgressResponse`, `SubmissionRepository` 쿼리 3개, `ProgressService`(`ExamScheduleService`, `TopicRepository` 재사용). 프론트 홈 게이지, `readinessCopy.ts` 24칸 매트릭스. 스펙 `docs/superpowers/specs/2026-04-10-readiness-score-design.md`, 플랜 `docs/superpowers/plans/2026-04-10-readiness-score.md`.

## 출처 (References)
- GitHub #52 이슈 본문, 프론트 구현 보고 댓글 (2026-04-10)
