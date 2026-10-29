---
type: decision
id: DEC-0182
created: 2026-10-26
reviewed: null
topics: [home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0405-home-first-load-skeleton-wait]]", "[[ISS-0405-home-first-load-skeleton-wait-report]]"]
---

# DEC-0182: 앱 홈 첫 표시는 추천 문제를 기다리지 않는다 (추천은 도착 후 맨 아래에 붙임)

## 문제 정의 (Context)
앱 홈이 세 묶음 모두 도착해야 그려져, 등급 확인 > 추천 직렬 요청(약 2.5초) 때문에 맨 위 카드까지 스켈레톤으로 기다렸다 (GitHub #676).

## 결정 (Decision)
- `homeDataProvider`는 인사말·일정 묶음과 학습 현황 묶음만 기다린다. 추천 문제는 `homeRecommendationsProvider`를 따로 구독해 도착하면 맨 아래 섹션으로 붙인다.
- 리포트 주의사항: "추천 문제를 다시 `homeDataProvider`에 합치지 않는다." `learning_refresh_test`의 `#676` 테스트로 강제.

## 검토한 대안 (Alternatives)
- 지난 데이터를 기기에 저장해 먼저 보여 주기(SWR): 대안이 아니라 이슈의 2단계로 남음(리포트 시점 미적용).
- 그 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 홈 내용 표시 평균 2476ms → 191ms(-92%, 시뮬레이터 디버그 측정).

**부정**
- 추천 문제 표시 시간 자체(약 2.5초)는 그대로.
- 추천 섹션을 위쪽으로 옮기면 도착 시 아래 카드가 밀려 자리 잡기 처리가 필요.

## 영향 범위 (Scope)
`app/lib/presentation/providers/home_providers.dart`, `app/lib/presentation/pages/home/home_page.dart`, `app/test/presentation/providers/learning_refresh_test.dart`.

## 출처 (References)
- GitHub #676 리포트 댓글 「주의사항」 (2026-10-26)
- [[ISS-0405-home-first-load-skeleton-wait]]
