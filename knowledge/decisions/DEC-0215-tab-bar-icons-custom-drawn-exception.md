---
type: decision
id: DEC-0215
created: 2026-10-29
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0116-app-apple-hig-design-system]]", "[[ISS-0430-app-bottom-tab-bar-icon-motion]]", "[[ISS-0430-app-bottom-tab-bar-icon-motion-report]]"]
---

# DEC-0215: 하단 탭 바 아이콘만 직접 그린 아이콘을 쓴다 (선택 시 같은 윤곽을 강조색으로 채우고 일부가 움직임)

## 문제 정의 (Context)
하단 탭 바에 토스처럼 선택될 때 아이콘 일부가 살짝 움직이는 반응을 넣기로 했다 (GitHub #755). 앱 아이콘은 Cupertino 폰트 아이콘으로 통일돼 있는데([[DEC-0116-app-apple-hig-design-system]]), 폰트 아이콘은 통째로만 움직일 수 있다.

## 결정 (Decision)
- 하단 탭 바 아이콘만 Cupertino 대신 직접 그린 선 아이콘(`PassqlTabIcon`)을 쓴다. 다른 화면의 아이콘 규칙(Cupertino 통일)은 그대로 유지하는 조건부 예외다.
- 선택 안 됨: 선 아이콘(`secondaryLabel`). 선택됨: 같은 윤곽을 강조색(`accentText`)으로 꽉 채우고, 뜻을 담은 곳(문제 탭 체크, 토론 탭 두 말풍선 사이 틈, 집게 둘레)만 뚫는다.
- 채운 모양이 선 아이콘 윤곽을 그대로 따르도록 홈은 문이 윤곽에 파인 집(직접 그림), 프로필은 원 없는 사람(Lucide `user`)으로 한다.
- 선택이 새로 켜질 때만 아이콘 일부가 짧게 움직인다 (홈 톡, 개념 전구 빛 반짝, 문제 체크 그리기, 토론 말풍선 통통, 프로필 끄덕임).
- 사용자 사유: "바텀네비는 저게 더 예뻐서 저렇게 하는 게 나아" (2026-10-29, W4 확인에서 조건부 유지 선택).

## 검토한 대안 (Alternatives)
- Lottie 애니메이션 파일: 아이콘 5개 움직임을 디자인할 사람이 필요하고 무료 파일은 스타일이 달라 제외.
- Cupertino 아이콘 통째 튕김: 가능하지만 사용자가 부품 움직임(시안 A)을 골랐다.
- 선택 모양: 연한 채움(20·35·50%), 선 색을 달리한 꽉 채움(어둡게·밝게), 같은 색 전체 채움(안쪽 뜻이 사라짐), 안쪽 선을 선 모양으로 뚫기를 차례로 비교한 끝에 "꽉 채움 + 뜻을 담은 곳만 뚫기"로 정함. 토스 탭 아이콘 스크린샷을 참고로 받음.
- 색: 토스처럼 선택·비선택 같은 글자색도 비교했으나, 라벨이 이미 강조색이라 아이콘도 강조색 유지.
- 프로필: 원 안 사람(지금), 둥근 어깨 사람, 네모 카드 안 사람 중 원 없는 사람(A).
- 결정 노트 처리: DEC-0116 대체 대신 조건부 유지(DEC-0116은 디자인 시스템 전체를 정한 결정이라).

## 결과 (Consequences)
**긍정**
- 선택 반응이 분명하고, 채운 아이콘과 선 아이콘이 같은 모양이라 탭 전환이 자연스럽다.

**부정**
- 아이콘 규칙에 예외가 하나 생긴다. 새 탭 아이콘은 Cupertino에서 고를 수 없고 경로를 직접 그려야 한다.
- Lucide 경로 사용으로 ISC 라이선스 문구를 코드에 유지해야 한다.

## 영향 범위 (Scope)
- `app/lib/presentation/design/components/passql_tab_icon.dart`, `passql_tab_icon_paths.dart`, `passql_tab_bar.dart`, `app/lib/presentation/widgets/app_shell.dart`
- 토큰: `PassqlSize.tabBar`(54)·`tabBarIconTop`, `PassqlMotion.tabIconSelect`
- 규칙 문서: `app/.claude/rules/Design.md`(아이콘 규칙 예외), `app/CLAUDE.md`

## 출처 (References)
- 이슈: [[ISS-0430-app-bottom-tab-bar-icon-motion]] (GitHub #755), 리포트 [[ISS-0430-app-bottom-tab-bar-icon-motion-report]]
