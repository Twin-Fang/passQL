---
type: issue
id: ISS-0430
created: 2026-10-29
topics: [design-system]
symptoms: ["하단 탭 바", "BNB", "아이콘 위 여백", "탭 아이콘 애니메이션", "선택 아이콘 채움", PassqlTabBar, PassqlTabIcon, CupertinoIcons]
root_cause: "탭 바 높이 49 안에서 아이콘·라벨이 가운데 정렬돼 아이콘 위 여백이 약 5.5pt뿐이었고, Cupertino 폰트 아이콘은 통째로만 움직일 수 있어 아이콘 일부가 움직이는 선택 반응을 넣을 수 없었다"
status: resolved
resolution: "[[ISS-0430-app-bottom-tab-bar-icon-motion-report]]"
related: ["[[ISS-0430-app-bottom-tab-bar-icon-motion-report]]", "[[DEC-0215-tab-bar-icons-custom-drawn-exception]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[LSN-0001-issue-branch-via-pro-skills]]"]
source: "https://github.com/Twin-Fang/passQL/issues/755"
---

# ISS-0430: 앱 하단 탭 바 아이콘 위 여백과 선택 애니메이션

GitHub #755 (원본: 이슈 본문).

## 증상
- 하단 탭 바 아이콘 위 여백이 너무 좁다 (약 5.5pt).
- 탭을 눌러 선택될 때 아이콘이 살짝 움직이는 반응이 없다 (사용자 참고: 토스 앱 탭 바).

## 재현 조건
메인 탭 셸(`app_shell.dart`)의 `PassqlTabBar` 어디서나. 높이 `PassqlSize.tabBar` 49 안에서 아이콘(24)과 라벨이 가운데 정렬.

## 조사 기록
- 2026-10-29: 탭 아이콘은 `CupertinoIcons`(폰트 아이콘, SVG 아님) > 아이콘 안의 일부만 움직이게 할 수 없음. Lottie는 애니메이션 파일 디자인이 필요해 제외, 직접 그리는 방식으로 정함.
- 2026-10-29: 브라우저 시안으로 움직임 3안(부분 움직임 / 선 그리기 / 통째 튕김) 비교 > 부분 움직임 선택. 비균등 확대로 선 굵기가 출렁여 "깨져 보임" > 균등 확대 + 선 굵기 고정으로 해결.

## 근본 원인
탭 바가 iOS 기본 높이 49에 내용을 가운데 정렬해 위 여백이 좁았고, 폰트 아이콘이라 부품 단위 움직임이 불가능했다.
