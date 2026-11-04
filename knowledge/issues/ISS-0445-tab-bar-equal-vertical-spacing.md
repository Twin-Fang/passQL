---
type: issue
id: ISS-0445
created: 2026-11-04
topics: [design-system]
symptoms: ["하단 탭 바 여백", "탭 바 위아래 여백 다름", "탭 아이콘 위 여백 큼", "광고 띠 화면 탭 바 아래 벌어짐", "하단 inset 0 최소 여백 8", "BNB", PassqlTabBar, tabBarIconTop, "PassqlSize.tabBar", passql_tab_bar.dart]
root_cause: "아이콘을 바 위 끝에서 10 띄우는 고정 여백(tabBarIconTop)과, 하단 inset이 0일 때도 더하던 최소 여백 8 때문에 아이콘·라벨 묶음의 위아래 여백이 달랐다"
status: resolved
resolution: "[[ISS-0445-tab-bar-equal-vertical-spacing-report]]"
related: ["[[ISS-0445-tab-bar-equal-vertical-spacing-report]]", "[[DEC-0241-tab-bar-content-vertically-centered]]", "[[DEC-0215-tab-bar-icons-custom-drawn-exception]]", "[[ISS-0430-app-bottom-tab-bar-icon-motion]]", "[[DEC-0153-single-native-strip-under-tab-bar]]"]
source: "https://github.com/Twin-Fang/passQL/issues/810"
---

# ISS-0445: 하단 탭 바 아이콘·라벨 위아래 여백을 같게, 최소로

GitHub #810 (원본: 완료 리포트 댓글. 이슈 본문은 이 노트 작성에 쓰지 않았다).

> 상태: 이 노트는 코드 PR과 같이 들어간다. 작성 시점(2026-11-04)에는 미머지·미배포다. 완료 리포트: [[ISS-0445-tab-bar-equal-vertical-spacing-report]]

## 증상
- 하단 탭 바(홈·문제·토론·프로필)의 아이콘 + 라벨 묶음 위 여백이 10, 아래 여백이 6으로 달랐다.
- 아래 광고 띠가 붙는 탭 화면에서는 아래가 8 더 벌어졌다.

## 재현 조건
`PassqlTabBar`가 있는 탭 화면 어디서나. 높이 `PassqlSize.tabBar` 54, 위 고정 여백 `tabBarIconTop` 10([[ISS-0430-app-bottom-tab-bar-icon-motion]]에서 넣은 값).

## 조사 기록
- 2026-11-04: 광고 띠가 붙는 탭 화면은 탭 바의 하단 inset을 지우는데, 그때도 최소 여백 8이 더해져 아래만 벌어지는 것을 확인했다.

## 근본 원인
위 고정 여백 10과 inset 0일 때의 최소 여백 8 때문에 위아래가 달랐다.
