---
type: decision
id: DEC-0198
created: 2026-10-28
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0420-questions-tab-trend-section-layout]]", "[[ISS-0420-questions-tab-trend-section-layout-report]]", "[[DEC-0189-home-section-layout-single-cta]]"]
---

# DEC-0198: 앱에서 고르는 목록은 카드, 위에서 아래로 읽는 리포트는 구간 — 문제 탭은 최신 경향·개념 TOP 10만 구간으로

## 문제 정의 (Context)
홈(GitHub #701)을 구간 방식으로 바꾼 뒤 문제 탭 안에서 카드와 구간이 섞였다 (GitHub #726 리포트 결정 기록 1).

## 결정 (Decision)
- 기준(이슈 본문): 고르는 목록(주제별, 바로가기)은 카드, 위에서 아래로 읽는 리포트(최신 경향, 개념 TOP 10)는 구간.
- 데이터 화면만 구간. 무료 잠금·오류·로딩 화면은 좌우 여백 안 카드 유지.
- 구간 제목은 흰 구간 안 맨 위, 꽉 찬 색 타일 26pt + 15pt 굵은 제목(결정 기록 2). 「최신 경향」 칩은 제목 줄로 대체(결정 기록 3).
- 개념 TOP 10 기준 문구는 서버 `basisDescription · updatedDate 갱신`(결정 기록 4).
- 광고는 원래 자리 유지, 구간 모양(결정 기록 5).

## 검토한 대안 (Alternatives)
리포트 결정 기록:
- 탭 전체를 구간으로: 이미 잘 된 주제별까지 바뀌어 버림(1).
- 회색 바탕 위로 뺀 제목, 바탕 없는 글리프, 옅은 타일, 17pt 제목: 버림(2, 결과 칸에 "15pt라 요약 문장(17pt)보다 튀지 않음").
- 칩을 구간 밖으로: 버림(3).
- 고정 문구 수정: 서버 값을 쓰면 문구가 바뀔 때 자동으로 따라가 버림(4).
- TOP 10을 한 구간으로 묶고 광고를 맨 아래로: 노출 감소로 버림(5).

## 결과 (Consequences)
**긍정**
- 위쪽(세그먼트·바로가기)은 세 보기 모두 같아 "내용만 바뀐" 느낌(결정 기록 1).

**부정**
- 세그먼트를 옮기면 아래 틀이 바뀐다(결정 기록 1).
- TOP 10이 광고를 사이에 두고 두 구간으로 나뉜다(두 번째는 제목 없음).

## 영향 범위 (Scope)
`app/lib/presentation/widgets/exam_trend/`, `pages/questions/topic_list_page.dart`, `widgets/ads/ad_native_slot.dart`, `design/components/passql_section*.dart`, `passql_icon_tile.dart`.

## 출처 (References)
- GitHub #726 이슈 본문, 리포트 「결정 기록」 1~5
- [[ISS-0420-questions-tab-trend-section-layout]], [[DEC-0189-home-section-layout-single-cta]]
