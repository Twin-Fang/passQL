---
type: decision
id: DEC-0241
created: 2026-11-04
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0215-tab-bar-icons-custom-drawn-exception]]", "[[DEC-0153-single-native-strip-under-tab-bar]]", "[[ISS-0445-tab-bar-equal-vertical-spacing]]", "[[ISS-0445-tab-bar-equal-vertical-spacing-report]]", "[[ISS-0430-app-bottom-tab-bar-icon-motion-report]]"]
---

# DEC-0241: 하단 탭 바는 아이콘 + 라벨 묶음을 바 안 세로 가운데에 두고 높이 50, 하단 inset 0이면 최소 여백을 더하지 않는다

## 문제 정의 (Context)
하단 탭 바의 아이콘 + 라벨 묶음이 위 10, 아래 6으로 여백이 달랐고, 아래 광고 띠가 붙는 탭 화면에서는 아래가 8 더 벌어졌다. 사용자가 위아래 여백을 같게, 최소로 맞추라고 요청했다 (GitHub #810). 위 10은 #755([[ISS-0430-app-bottom-tab-bar-icon-motion-report]])에서 넣은 `tabBarIconTop`이다.

## 결정 (Decision)
- 탭 내용(아이콘 24 + 간격 2 + 라벨 12)을 바 높이 안 **세로 가운데**에 둔다. 위 고정 여백 `tabBarIconTop`은 없앤다.
- 탭 바 높이 `PassqlSize.tabBar`는 54 > 50. 위아래 여백은 기본 글자 크기에서 6 / 6, 글자 크기 상한 1.4배에서 3.6 / 3.6.
- 하단 inset이 0이면 최소 여백 8을 더하지 않는다.
- [[DEC-0215-tab-bar-icons-custom-drawn-exception]](직접 그린 탭 아이콘, 선택 움직임)은 그대로다. DEC-0215는 아이콘 모양을 정한 결정이고 위 여백 10을 결정으로 정하지 않았으므로 대체하지 않는다(영향 범위의 토큰 값 54·`tabBarIconTop`만 바뀜).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 가운데 정렬이라 글자 크기가 바뀌어도 위아래 여백이 늘 같다.

**부정**
- 탭 바 높이가 4 줄어 탭 바 높이를 쓰는 탭 화면 콘텐츠 하단 여백도 4 줄어든다.
- 다크 모드, 큰 글자 설정, Android는 작성 시점에 실기기로 확인하지 않았다.

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_tab_bar.dart`, `app/lib/presentation/design/tokens/passql_size.dart`(`tabBar`, `tabBarIconTop` 삭제), 탭 바 높이를 쓰는 탭 화면 하단 여백.

## 출처 (References)
- GitHub #810 완료 리포트 댓글 (2026-11-04)
- 이슈: [[ISS-0445-tab-bar-equal-vertical-spacing]], 리포트 [[ISS-0445-tab-bar-equal-vertical-spacing-report]]
