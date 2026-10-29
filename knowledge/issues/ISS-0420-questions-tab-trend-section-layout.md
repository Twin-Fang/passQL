---
type: issue
id: ISS-0420
created: 2026-10-28
topics: [design-system, question-bank]
symptoms: ["문제 탭 경향 화면 카드 묶음", "개념 TOP 10 기준 문구 불일치", "최근 4회 합산", "세그먼트 순간이동", passql_segmented_control.dart]
root_cause: "문제 탭 최신 경향·개념 TOP 10이 홈(#701)과 다른 카드 묶음이었고, TOP 10 기준 문구가 고정 문구라 실제 데이터와 맞지 않았다"
status: resolved
resolution: "[[ISS-0420-questions-tab-trend-section-layout-report]]"
related: ["[[DEC-0198-cards-for-pick-lists-sections-for-reports]]", "[[DEC-0189-home-section-layout-single-cta]]"]
source: "https://github.com/Twin-Fang/passQL/issues/726"
---

# ISS-0420: 문제 탭 경향 화면 구간 개편 (앱)

GitHub #726 (원본: 이슈 본문과 댓글).

## 증상
- 문제 탭 「최신 경향」「개념 TOP 10」이 둥근 카드 묶음이라 홈(GitHub #701) 구간 방식과 톤이 다르다.
- 개념 TOP 10 맨 아래 "최근 4회(58·60·61·62회) 합산 출제 문항 수 기준"이 실제 데이터("5회 합계", 58~62회 분석)와 맞지 않는다.
- 세그먼트(주제별 / 최신 경향 / 개념 TOP 10) 선택이 애니메이션 없이 바로 바뀐다.

## 재현 조건
앱 문제 탭에서 최신 경향·개념 TOP 10 보기.

## 조사 기록
- 이슈 본문: 앱만 바꾸고 서버·웹은 바꾸지 않는다. 같은 공통 컴포넌트를 쓰는 홈 등은 모양이 바뀌지 않게(세그먼트는 함께 바뀜). 1~3 확정 시안, 5 세그먼트 시안 첨부. 이전 관련 GitHub #701, #523.
- 2026-10-28 리포트: 결정 기록 7건과 구현.

## 근본 원인
TOP 10 문구는 고정 문구였다(리포트 결정 기록 4). 레이아웃은 디자인 개선 요청.
