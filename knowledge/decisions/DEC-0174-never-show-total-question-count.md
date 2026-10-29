---
type: decision
id: DEC-0174
created: 2026-10-24
reviewed: null
topics: [progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0365-profile-bar-shows-total-questions]]", "[[ISS-0365-profile-bar-shows-total-questions-report]]"]
---

# DEC-0174: (사용자 결정) 카테고리 막대는 푼 문제 수의 상대 비율로 보이고, 전체 문제 수는 사용자에게 어디에서도 보여 주지 않는다

## 문제 정의 (Context)
내 프로필 카테고리별 막대가 전체 등록 문제 수를 보여 줘 아무것도 안 푼 계정에서도 가득 차 있었다 (GitHub #609).

## 결정 (Decision)
이슈 본문 「결정 (사용자)」:
- 막대는 내가 푼 문제 수 기준, 카테고리끼리 상대 비율로 표시(가장 많이 푼 카테고리 = 100%).
- 전체 문제 수는 사용자에게 어디에서도 보여 주지 않는다(분모 `3 / 35` 형태 금지).

## 검토한 대안 (Alternatives)
- 분모 표시(`3 / 35`): 금지로 적혔다. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 레이더 차트(0%)와 막대가 어긋나지 않는다.

**부정**
- 서버 응답의 `totalQuestionCount`는 남아 네트워크에서는 보인다(화면 노출만 제거).

## 영향 범위 (Scope)
앱 `bar_chart_section.dart`, 웹 `StatsBarChart.tsx` 제목, 앱·웹에서 전체 문제 수를 노출하는 다른 곳 점검(이슈 작업 항목). 예외: 출제 경향의 "N문항 · 20%"는 경향 분석 문항 수라 유지. GitHub #586 스토어 문구 "300문제 이상"과의 관계는 원본에 언급 없음.

## 출처 (References)
- GitHub #609 이슈 본문, 리포트 댓글(2026-10-24)
- [[ISS-0365-profile-bar-shows-total-questions]]
