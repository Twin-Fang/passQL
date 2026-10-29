---
type: decision
id: DEC-0078
created: 2026-04-13
reviewed: null
topics: [progress-stats]
status: active
supersedes: DEC-0033
superseded_by: null
related: ["[[ISS-0143-readiness-formula-multiplicative-core-bonus]]", "[[DEC-0033-readiness-replaces-progress-rate]]"]
---

# DEC-0078: 합격 준비도 = 3요소 곱셈 코어(Accuracy × Coverage × Recency) × 2요소 보너스 계수

## 문제 정의 (Context)
현행 6요소 가중 평균 산식은 한 요소가 높으면 나머지가 낮아도 묻혀 1문제만 풀어도 100%가 나왔다(GitHub #262). 이 6요소 산식이 어느 이슈에서 들어왔는지는 원본에 적혀 있지 않다. 그 이전 볼트 결정은 DEC-0033(GitHub #52, 3요소 곱셈, 가중치 없음).

## 결정 (Decision)
```
score = clamp(base × bonus, 0, 1)
base  = Accuracy × Coverage × Recency
bonus = 1 + (retry_boost × 0.10) + (spread_boost × 0.05)
```
| 요소 | 역할 | 계산 |
|---|---|---|
| Accuracy | 주 점수 | 최근 50문제 정답률 |
| Coverage | 필수 조건 | 최근 14일 내 건드린 활성 토픽 비율 |
| Recency | 감쇠 계수 | 0.70~1.00 |
| retry_boost | 보너스 | 틀린 문제 재도전 정답 비율(0~1), 최대 +10% |
| spread_boost | 보너스 | Shannon 엔트로피 기반 토픽 균등도(0~1), 최대 +5% |

`Difficulty` 요소는 제거한다(`computeDifficulty`, `ReadinessResult`·`ReadinessResponse`의 `difficulty` 필드 제거).

## 검토한 대안 (Alternatives)
- 6요소 가중 평균(현행): 한 요소가 높으면 나머지가 묻히고, `Difficulty`·`Retry`·`Spread`가 데이터 부족 시 불안정하며 `Coverage`와 의미가 겹쳐서 교체(이슈 본문).
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이슈 본문 시나리오: 1문제만 맞힘 11%, 편식 고수 32%, 골고루 중수 62%, 탑 학습자 90%, 오래 방치 60%.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
백엔드 `ReadinessConstants.java`(`WEIGHT_*` 제거, `BONUS_RETRY`/`BONUS_SPREAD` 추가), `ReadinessCalculator.java`, `ProgressService.java`, `ReadinessResponse.java`. 프론트 `src/types/api.ts`, `src/pages/Home.tsx`, `src/pages/Stats.tsx`.

## 출처 (References)
- GitHub #262 이슈 본문 (2026-04-13)
- [[ISS-0143-readiness-formula-multiplicative-core-bonus]]
