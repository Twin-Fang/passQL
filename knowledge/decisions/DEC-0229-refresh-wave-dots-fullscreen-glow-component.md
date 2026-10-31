---
type: decision
id: DEC-0229
created: 2026-10-31
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0436-app-pull-to-refresh-glow-indicator]]", "[[DEC-0222-concept-perfect-fullscreen-scoreboard]]", "[[DEC-0230-refresh-dots-above-large-title-fixed]]", "[[DEC-0231-refresh-glow-on-release-wave-while-holding]]", "[[DEC-0136-motion-via-tokens-only]]"]
---

# DEC-0229: 당겨서 새로고침은 iOS 스피너 대신 웨이브 점과 화면 전체 빛을 그리는 공통 컴포넌트 하나로 쓴다

## 문제 정의 (Context)
앱에서 당겨서 새로고침하면 iOS 기본 회색 스피너가 떴다. 개념 점수판(#764)에서 만든 보라 빛 번짐과 결이 달라서, 그 빛을 새로고침 표시에도 쓰기로 했다 (GitHub #772). 새로고침이 있는 곳은 5곳이다.

## 결정 (Decision)
- 디자인 시스템 공통 컴포넌트 `PassqlRefreshControl` 하나를 5곳이 함께 쓴다: 홈 틀, 큰 제목 틀, 공지 목록, 토론 질문, 알림함.
- 화면(pages·widgets·flows)에서 `CupertinoSliverRefreshControl(`을 직접 쓰지 못하게 디자인 규칙 테스트로 막는다.
- 표시는 점 5개다. 색은 강조색에서 탑승권 보라로 가며, 가운데 점일수록 보라에 가깝다. 당긴 만큼 왼쪽부터 켜지고, 물결은 점이 차례로 솟았다 내려오는 모양이다.
- 빛은 점 자리에서 화면 전체로 번지는 보라 빛이다. 앱 맨 위 층(오버레이)에 그리고, 누름은 막지 않는다.
- 개념 점수판의 빛(`widgets/concept/concept_glow.dart`, `ConceptGlow`)을 디자인 시스템 `PassqlGlow`(`design/components/passql_glow.dart`)로 옮겼다. 점수판과 새로고침이 같은 빛을 쓴다.
- 동작 줄이기가 켜져 있으면 물결과 빛 없이 켜진 점만 보인다.
- 시간 값은 `PassqlMotion` 토큰으로만 쓴다 ([[DEC-0136-motion-via-tokens-only]]).

## 검토한 대안 (Alternatives)
- 이슈 첫 계획: 작은 원과 차오르는 고리. 구현해 보니 사용자가 "너무 별로, 액티비티한 파동 느낌으로"라고 해서 바꿨다.
- 새 표시 시안 4개를 움직이는 상태로 비교했고, 사용자가 A를 골랐다.
  - A: 웨이브 점 (채택)
  - B: 이퀄라이저 막대
  - C: 소나 펄스
  - D: 사인파 선
  - 시안에 적었던 설명: B는 음악 앱 느낌이 남고, C는 원래의 점과 고리에 가깝고, D는 작아서 눈에 덜 띈다.
- 빛을 새로고침 띠 안에서만 번지게 하기 (이슈 본문 계획): 사용자가 "화면 전체로, 토스처럼"이라고 해서 화면 전체로 바꿨다.

## 결과 (Consequences)
**긍정**
- 새로고침 표시가 개념 점수판과 같은 브랜드 결로 보이고, 5곳이 같은 표시를 쓴다.
- 빛 그리기 코드가 한 벌이다.

**부정**
- 빛을 앱 맨 위 층에 띄우므로, 점 위치를 재고 빛의 수명을 관리하는 일을 직접 해야 한다.
- Cupertino 새로고침 상태만으로는 손 뗌을 알 수 없어서, 전역 포인터 손 뗌을 따로 받는다 ([[DEC-0231-refresh-glow-on-release-wave-while-holding]]).
- `PassqlGlow`를 고치면 개념 점수판 빛도 같이 바뀐다.

## 영향 범위 (Scope)
- 컴포넌트: `app/lib/presentation/design/components/passql_refresh_control.dart`(신규), `passql_glow.dart`(`concept_glow.dart`에서 옮김), `design.dart`(export)
- 시간 토큰: `tokens/passql_motion.dart`
- 큰 제목 틀·홈 틀: `passql_large_title_scroll_view.dart`, `passql_brand_bar_scroll_view.dart`
- 새로고침을 직접 둔 화면: `pages/notice/notice_list_page.dart`, `pages/community/community_question_page.dart`, `widgets/notification/notification_inbox_list.dart`
- 개념 점수판: `widgets/concept/concept_perfect_page.dart`
- 규칙 테스트: `test/architecture/design_system_rules_test.dart`

## 출처 (References)
- GitHub #772 이슈 본문과 구현 세션의 시안 비교
- [[ISS-0436-app-pull-to-refresh-glow-indicator]]
