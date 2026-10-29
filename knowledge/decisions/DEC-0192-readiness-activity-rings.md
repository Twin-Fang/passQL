---
type: decision
id: DEC-0192
created: 2026-10-27
reviewed: null
topics: [home, progress-stats, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0413-app-home-ui-ux-redesign]]", "[[ISS-0413-app-home-ui-ux-redesign-report]]"]
---

# DEC-0192: 앱 홈 합격 준비도는 겹친 링 3개(정확도·범위·최신성) + 범례로, 색은 기존 앱 토큰

## 문제 정의 (Context)
합격 준비도의 정확도·범위·최신성을 홈에서 어떻게 표현할지 정해야 했다. 기존은 큰 점수 + 진행 막대 + 숫자 세 칸 카드 (GitHub #701 리포트 결정 기록 4).

## 결정 (Decision)
- 홈은 겹친 링 + 오른쪽 범례, 가운데 점수. 색은 앱 토큰(정확도 강조 보라, 범위 정답 초록, 최신성 주의 주황).
- 기록이 없으면 빈 링 + "첫 세트를 풀면 합격 준비도가 채워져요".
- 통계 화면은 기존 카드 그대로(`ReadinessCard`의 `isSection`).
- 모양 참고: Apple 피트니스 링.

## 검토한 대안 (Alternatives)
리포트 결정 기록 4에서 버린 대안: 숫자 세 칸(현행), 가로 막대, 작은 링 셋, 꺾은선(준비도 과거 기록 API 없음), 새 전용 색(블루·틸·퍼플), 파랑·노랑·빨강(오답·주의 색과 충돌). 꺾은선과 파랑·노랑·빨강 외에는 버린 이유가 표에 따로 없다.

## 결과 (Consequences)
**긍정**
- 새 색을 만들지 않음.

**부정**
- 초록·주황이 앱의 "정답·주의" 뜻과 겹쳐 범위 링이 항상 초록이라 "잘함"으로 읽힐 수 있다. 범례 숫자로 보완(결정 기록 4).

## 영향 범위 (Scope)
`app/lib/presentation/widgets/home/readiness_card.dart`, `design/components/passql_activity_rings.dart`, `widgets/home/fallback_stats_section.dart`.

## 출처 (References)
- GitHub #701 리포트 결정 기록 4, 확정 댓글 「구간 순서」 2
- [[ISS-0413-app-home-ui-ux-redesign]]
