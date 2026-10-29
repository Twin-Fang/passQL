---
type: issue
id: ISS-0021
created: 2026-04-08
topics: [progress-stats]
symptoms: ["학습 진도 집계", "/api/progress", 스트릭, StreakCalculator, 정답률, solvedCount]
root_cause: "홈 통계 카드·스트릭 뱃지를 채울 사용자별 학습 진도 집계 API가 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0021-progress-api-streak-calculator-report]]"
related: ["[[DEC-0024-progress-metric-definitions]]", "[[DEC-0015-zero-business-logic-in-frontend]]"]
source: "https://github.com/Twin-Fang/passQL/issues/25"
---

# ISS-0021: Progress API 및 StreakCalculator

GitHub #25 (원본: 이슈 본문과 댓글).

## 증상
홈 통계 카드(푼 문제 수, 정답률)와 스트릭 뱃지를 채울 집계 API가 없었다. 통계 화면도 같은 API를 써야 해 단일 엔드포인트가 필요했고, "프론트 비즈니스 로직 제로 원칙"에 따라 정답률 반올림과 스트릭 계산은 백엔드 책임이라고 적었다.
제안: `GET /api/progress?memberUuid=` → `{ solvedCount, correctRate, streakDays }`, 회원 없음 404, 제출 0건은 200 + `{0, 0.0, 0}`. 어드민 submission 보정은 범위 외.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-08: `## 개요` 리포트 댓글 (아래 리포트).

## 근본 원인
해당 없음 (기능 이슈).
