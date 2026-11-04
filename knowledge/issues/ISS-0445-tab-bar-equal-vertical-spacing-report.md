---
type: completion-report
id: ISS-0445
created: 2026-11-04
topics: [design-system]
status: resolved
resolves: "[[ISS-0445-tab-bar-equal-vertical-spacing]]"
related: ["[[DEC-0241-tab-bar-content-vertically-centered]]", "[[DEC-0215-tab-bar-icons-custom-drawn-exception]]", "[[ISS-0430-app-bottom-tab-bar-icon-motion-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/810"
---

# ISS-0445 완료 리포트: 탭 바 내용 세로 가운데, 높이 54 > 50, inset 0이면 최소 여백 없음

GitHub #810 리포트 댓글 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0445-tab-bar-equal-vertical-spacing-report.md` (로컬 전용).

> 머지 상태: 작성 시점(2026-11-04)에 미머지·미배포. 코드 커밋은 `dc49f051`이고 #809 브랜치에 함께 쌓였다. 이 노트는 그 코드 PR과 같이 들어간다.

## 해결 방법
- `app/lib/presentation/design/components/passql_tab_bar.dart`: 탭 내용(아이콘 24 + 간격 2 + 라벨 12)을 바 높이 안 세로 가운데에 둔다. 위 끝에서 10 띄우던 고정 여백(`tabBarIconTop`)을 없앴다. 하단 inset이 0이면 최소 여백 8을 더하지 않는다.
- `app/lib/presentation/design/tokens/passql_size.dart`: `tabBar` 54 > 50, `tabBarIconTop` 삭제.
- 결과 여백: 이전 위 10 / 아래 6(+ 광고 띠 화면 8 더), 이후 위 6 / 아래 6, 글자 크기 상한 1.4배에서 3.6 / 3.6.
- **검증:** 앱 테스트 98개 통과. iOS 시뮬레이터(iPhone 16 Pro, 라이트, 기본 글자 크기) 수정 전후 캡처로 위아래 여백이 같아진 것을 확인했다.

## 근본 원인 (확정)
위 고정 여백(`tabBarIconTop` 10)과 하단 inset 0일 때도 더하던 최소 여백 8 때문에 위아래가 달랐다.

## 재발 방지
- 가운데 정렬이라 글자 크기가 바뀌어도 위아래가 늘 같다. 기준은 [[DEC-0241-tab-bar-content-vertically-centered]].

## 알고 남긴 것
- 다크 모드, 큰 글자 설정, Android는 실기기로 보지 않았다(#809 테스트 빌드에서 확인).
- 탭 바 높이가 4 줄어 탭 바 높이를 쓰는 탭 화면 콘텐츠 하단 여백도 4 줄어든다.

## 교훈
- 하단 inset을 지우는 화면(아래 광고 띠)에서는 "최소 여백" 보정이 오히려 여백을 만든다. inset이 0일 때의 경로를 따로 확인한다.
