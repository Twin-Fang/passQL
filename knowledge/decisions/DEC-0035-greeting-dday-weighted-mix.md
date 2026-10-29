---
type: decision
id: DEC-0035
created: 2026-04-10
reviewed: null
topics: [home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0036-greeting-response-schema-split]]", "[[ISS-0036-greeting-response-schema-split-report]]"]
---

# DEC-0035: D-day 구간에도 일반 인사말을 섞고, 시험이 가까울수록 D-day 메시지 비중을 높인다

## 문제 정의 (Context)
메시지 선택이 구간 단위 단일 풀이라 D-7·D-30 이내에 들어가면 긴급 메시지만 반복됐다. 이슈 본문은 "매일 들어오는 사용자 입장에서 다양성이 부족하고 피로감이 있음"이라고 적었다 (GitHub #53).

## 결정 (Decision)
| 구간 | D-day 메시지 | 일반 메시지 |
|---|---|---|
| D-0 | `EXAM_DAY` 100% | 0% |
| D-1~3 | `URGENT` 70% | 30% |
| D-4~7 | `URGENT` 50% | 50% |
| D-8~30 | `COUNTDOWN` 40% | 60% |
| D-30 초과 / 시험 종료 | 0% | `GENERAL` 100% |

풀을 합치지 않고, 가중치 합 범위에서 먼저 어느 풀에서 뽑을지 정한 뒤 그 풀 안에서 균등 추출한다(`weightedPick`).

## 검토한 대안 (Alternatives)
- 두 풀을 `addAll`로 합쳐 균등 랜덤: 리포트는 풀 크기 차이로 의도한 비율이 깨진다고 적었다(예: urgent 5개 + general 8개 → urgent 38%).
- 구간별 단일 풀(기존): 이 결정으로 대체.

## 결과 (Consequences)
**긍정**
- 리포트: 풀 크기에 영향받지 않고 의도한 비율이 정확히 유지된다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`GreetingService.buildMessage`, `weightedPick`, 메시지 풀(`generalMessages`, `examDayMessages`, `urgentMessages`, `countdownMessages`).

## 출처 (References)
- GitHub #53 이슈 본문 「D-day 구간 메시지 혼합」, `## 개요` 리포트 댓글 「가중치 기반 풀 선택 로직」(2026-04-10)
