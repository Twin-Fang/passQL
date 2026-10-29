---
type: issue
id: ISS-0218
created: 2026-10-07
topics: [progress-stats]
symptoms: ["최신성 70%", "신규 가입 직후", "합격 준비도", ReadinessCalculator.computeRecency, RECENCY_DEFAULT]
root_cause: "학습 기록이 없을 때(`lastStudiedAt == null`)도 최신성에 바닥값 0.70이 적용됐다"
status: resolved
resolution: "[[ISS-0218-readiness-recency-new-user-70-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/373"
---

# ISS-0218: 신규 가입 직후 합격 준비도 최신성이 70%로 표시됨

GitHub #373 (원본: 이슈 본문과 완료 댓글). GitHub #370 후보 3.

## 증상
신규 가입 직후(푼 문제 0개) 홈 합격 준비도 카드가 정확도 0%, 범위 0/9인데 최신성 70%로 표시된다.

## 재현 조건
새 계정 가입 직후 홈 진입.

## 조사 기록
- 2026-10-07: 서버 readiness 계산에서 기록 없음일 때 최신성 값 확인.

## 근본 원인
`ReadinessCalculator.computeRecency`가 학습 기록이 없을 때도 15일 이상 쉰 경우의 바닥값 0.70(`RECENCY_DEFAULT`)을 돌려줬다 (완료 댓글의 수정 내용에서 읽힘).
