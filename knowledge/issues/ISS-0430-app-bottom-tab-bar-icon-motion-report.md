---
type: completion-report
id: ISS-0430
created: 2026-10-29
topics: [design-system]
status: resolved
resolves: "[[ISS-0430-app-bottom-tab-bar-icon-motion]]"
related: ["[[DEC-0215-tab-bar-icons-custom-drawn-exception]]", "[[DEC-0116-app-apple-hig-design-system]]"]
source: "https://github.com/Twin-Fang/passQL/issues/755"
---

# ISS-0430 완료 리포트: 하단 탭 아이콘 직접 그리기, 선택 움직임, 위 여백 10pt

GitHub #755 리포트 댓글 기준 (2026-10-29).

## 해결 방법
- `PassqlTabIcon`(+`PassqlTabIconKind`)을 새로 만들어 아이콘 5종을 `CustomPainter`로 직접 그림. 경로는 `passql_tab_icon_paths.dart`(Lucide ISC + 직접 그린 홈·빛줄기, `path_parsing`으로 변환).
- 선택이 false > true로 바뀔 때만 600ms 컨트롤러를 재생하고 부품별 구간으로 나눔 (`PassqlMotion.tabIconSelect`). 앱 시작·같은 탭 다시 누름은 재생 없음, 동작 줄이기면 정지.
- 선택 모양: 같은 윤곽을 강조색으로 꽉 채우고 체크·말풍선 사이 틈·집게 둘레만 뚫음([[DEC-0215-tab-bar-icons-custom-drawn-exception]]).
- `PassqlSize.tabBar` 49 > 54, `tabBarIconTop` 10. 탭 칸이 바 높이를 꽉 채우고(누르는 영역 유지), 탭마다 `ValueKey(kind)`.
- 커밋: 8abb8389, 981e01ae, 9dfb31dc.

## 근본 원인 (확정)
가운데 정렬된 49pt 탭 바와 폰트 아이콘의 한계 (이슈 노트 참고).

## 재발 방지
- 채운 아이콘에서 뚫는 그리기(`BlendMode.clear`)는 아이콘만의 층(saveLayer) 안에서만. 층 없이 쓰면 탭 바 흐림 바탕까지 지워진다.
- 탭 칸 `ValueKey(kind)`를 지우면 개념 탭이 뒤늦게 나타날 때 누르지 않은 탭이 움직인다 (최종 리뷰에서 발견).
- 새 탭 아이콘은 채운 모양이 선 아이콘 윤곽을 그대로 따르도록 그린다. 안쪽 장식 선이 많으면 채울 때 뜻이 사라진다(원 안 사람이 그 예).

## 교훈
- 아이콘 움직임이 "깨져 보인다"면 먼저 비균등 확대와 선 굵기 변화를 의심한다.
- 확인하지 못한 것: Android 3버튼 내비게이션 실기기, 글자 크기 1.4배 화면.
