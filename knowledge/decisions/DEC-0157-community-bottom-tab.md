---
type: decision
id: DEC-0157
created: 2026-10-18
reviewed: null
topics: [community, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0333-app-community-bottom-tab]]", "[[ISS-0333-app-community-bottom-tab-report]]"]
---

# DEC-0157: 앱 하단 탭에 "토론" 탭을 넣는다 (홈 · 문제 · 토론 · 통계 · 설정, 웹과 같은 순서)

## 문제 정의 (Context)
앱에서 커뮤니티는 설정 안 "내 의견"으로만 들어갈 수 있어 접근성이 낮았고, 웹은 이미 하단 탭에 "토론"이 있었다 (GitHub #543). GitHub #525 설계 댓글은 앱이 하단 탭 4개를 유지하고 커뮤니티를 push 화면으로 둔다고 적었었다.

## 결정 (Decision)
- 하단 탭을 5개로: 홈 · 문제 · 토론 · 통계 · 설정 (웹과 같은 순서).
- 토론 탭 첫 화면은 기존 피드(뜨는 토론 · 최신 경향 · 내가 푼 문제 · 내 의견).
- 설정의 "내 의견"은 탭으로 대체. 홈 "오늘의 토론" 카드와 풀이 하단 "의견" 칩은 유지.

리포트(2026-10-26) 시점에는 GitHub #602에서 통계·설정이 "내 프로필"로 합쳐져 `홈 · 문제 · 토론 · 내 프로필` 4개다.

## 검토한 대안 (Alternatives)
- 커뮤니티를 push 화면으로 두고 하단 탭 4개 유지(GitHub #525 설계): 접근성이 낮아 탭으로 바꿨다(이슈 본문).

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- SE 폭 라벨 잘림은 실기기로 확인하지 않았다.

## 영향 범위 (Scope)
앱 `app_shell.dart`, `app_router.dart`, `app_routes.dart`, `community_feed_page.dart`, `settings_page.dart`, `app_shell_test.dart`. 하단 탭을 `홈 / 문제 / 통계 / 설정` 4탭으로 정한 기존 결정 DEC-0018과 탭 구성이 다르다.

## 출처 (References)
- GitHub #543 이슈 본문 (2026-10-18), 리포트 댓글 (2026-10-26), GitHub #525 설계 댓글
- [[ISS-0333-app-community-bottom-tab]]
