---
type: completion-report
id: ISS-0420
created: 2026-10-28
topics: [design-system, question-bank]
status: resolved
resolves: "[[ISS-0420-questions-tab-trend-section-layout]]"
related: ["[[DEC-0198-cards-for-pick-lists-sections-for-reports]]"]
source: "https://github.com/Twin-Fang/passQL/issues/726"
---

# ISS-0420 완료 리포트: 최신 경향·개념 TOP 10을 구간으로, 색 타일 제목, 세그먼트 물방울 이동

GitHub #726 리포트 댓글 기준.

## 해결 방법
- 공통 컴포넌트: `passql_section.dart`·`passql_section_header.dart` `isCompactTitle`(15pt, 기본값 그대로라 홈 무변화), `passql_icon_tile.dart` `isCompact` 26pt, `topic_appearance.dart` `systemHueColor`, `.claude/rules/Design.md` 갱신.
- 경향 구간: `exam_trend_sections.dart` `PassqlGroupedSection` → `PassqlSection`, 요약 구간이 「최신 경향」 칩 대신 제목, 구간별 아이콘·색(불꽃 주황, 파이 파랑, 오름 화살표 초록, 전구 노랑, 순위 목록 보라). 개념 구간 꼬리 문구 대신 제목 아래 `basisCaption`(서버 `basisDescription · updatedDate 갱신`). `concept_ranking_tab_view.dart`는 `report`를 받음, 1~5위 > (광고) > 6~10위. `topic_list_page.dart`는 데이터 화면만 좌우 여백 0, 잠금·오류·로딩은 카드 유지.
- 광고: `ad_native_slot.dart` `isSection`(광고가 뜬 뒤에만 앞 띠 + 구간).
- 세그먼트: `passql_segmented_control.dart` 트랙 여백 2 → 4, 알약 40 → 36(누르는 높이 44 유지), 둥글기 트랙 12·알약 8, 물방울 이동(`segmentMorph` 350ms, 앞 가장자리 `Interval(0, 0.63)`, 뒤 `Interval(0.14, 1)`), 동작 줄이기면 바로 이동. 알림함·개념 학습 2곳·설정 화면 모드에도 적용.
- 검증: `flutter analyze` 문제 없음, `flutter test` 59개 통과, 시뮬레이터 다크·라이트 확인, `ad_placement_rules_test` 문제 탭 네이티브 광고 호출 3개 유지.

## 근본 원인 (확정)
고정 기준 문구와 화면별로 다른 레이아웃 방식.

## 재발 방지
- `PassqlSection` 15pt 제목은 위 여백이 1pt 넓다(`verticalSlack`이 17pt 기준).
- 경향 행 위아래 여백은 구간(`_TrendSection`)이 준다 — 행 위젯에 다시 넣으면 간격 두 배.
- 광고 앞 띠는 광고 위젯이 그린다 — 보기 쪽에서 띠를 추가하면 광고 미로드 시 띠가 겹친다.
- 세그먼트는 칸 폭이 같다고 가정.
- 확인하지 못함: 수정 전 라이트 화면, 세그먼트를 같이 쓰는 알림함·개념 학습·설정 화면(세그먼트 변경은 별도 리뷰 없음), 광고 미로드 실제 화면.
- 남은 작은 개선 4개: 제목 타일 색 누락 시 멈춤 가능성, 문구 두 곳 중복, 15pt 제목 1pt, 개념 목록이 비면 "TOP 0".

## 교훈
(원본에 없음, 볼트 정리) 데이터 기준을 설명하는 문구는 고정 문자열이 아니라 서버 값으로 받아야 데이터가 바뀔 때 어긋나지 않는다.
