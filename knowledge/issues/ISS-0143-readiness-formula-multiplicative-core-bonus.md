---
type: issue
id: ISS-0143
created: 2026-04-13
topics: [progress-stats]
symptoms: ["합격 준비도 100%", "1문제만 풀어도 100%", "6요소 가중 평균", ReadinessCalculator, ReadinessConstants, Coverage, difficulty]
root_cause: "6요소 가중 평균 산식은 한 요소가 높으면 나머지가 낮아도 묻혀, 1문제만 풀어도 준비도 100%가 나옴"
status: resolved
resolution: null
related: ["[[DEC-0078-readiness-multiplicative-core-with-bonus]]"]
source: "https://github.com/Twin-Fang/passQL/issues/262"
---

# ISS-0143: 합격 준비도가 1문제만 풀어도 100%가 나오는 산식 결함

GitHub #262 (원본: 이슈 본문, 댓글은 시스템 아키텍처 mermaid 다이어그램 2개로 완료 내용 없음).

## 증상
현행 6요소 가중 평균 산식은 1문제만 풀어도 합격 준비도 100%가 나온다. `Accuracy=1.0, Recency=1.0, Retry=1.0`이면 `Coverage=11%`여도 높은 점수. `Difficulty`, `Retry`, `Spread`는 데이터가 적을 때 불안정하고 `Coverage`와 의미가 겹친다.

## 재현 조건
문제 1개만 풀고 정답 → 준비도 확인.

## 조사 기록
- 2026-04-13: 3요소 곱셈 코어 + 2요소 보너스 계수로 재설계 제안, 시나리오 표로 검증([[DEC-0078-readiness-multiplicative-core-with-bonus]]).
- 2026-04-13 댓글: 전체 시스템 아키텍처 mermaid 다이어그램 2개(이슈 작업 결과와 직접 관련된 설명 없음).

## 근본 원인
가중 평균 구조. 구현 완료 여부는 원본에 적혀 있지 않다(닫힘 상태만 있음).
