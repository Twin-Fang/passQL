---
type: decision
id: DEC-0190
created: 2026-10-27
reviewed: null
topics: [home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0413-app-home-ui-ux-redesign]]", "[[ISS-0413-app-home-ui-ux-redesign-report]]"]
---

# DEC-0190: 앱 홈의 시험 일정 카드를 없애고 상단 바 로고 자리에 시험 D-day를 둔다

## 문제 정의 (Context)
시험 일정이 홈에서 카드 한 장을 차지했다 (GitHub #701 이슈 본문 「확정」, 리포트 결정 기록 2).

## 결정 (Decision)
- 상단 바 왼쪽(passQL 로고 자리)에 큰 `D-18`(강조색) + 작은 회색 `SQLD 63회 · 11월 14일`. 시험 당일 `D-Day`, 지난 경우 `D+3`(기존 카드와 같은 규칙).
- 일정 없음: 로고 + "시험 일정 준비 중"(확정 댓글).
- 좁은 화면·큰 글자에서는 날짜를 먼저 뺀다. 스크린리더는 "시험까지 18일".
- 시험 일정 카드(`exam_schedule_card.dart`)와 2열 카드 배치 삭제, 「오늘의 세트」는 전체 폭.
- D-day 시안은 B안 채택(이슈 본문).

## 검토한 대안 (Alternatives)
- 인사말 위 한 줄, 큰 D-day 제목: 버림(리포트 결정 기록 2, 이유는 표에 따로 없음).

## 결과 (Consequences)
**긍정**
- 카드 한 장이 줄어든다.

**부정**
- 상단 바 밀도가 올라감. 좁은 폭에서는 회차·날짜가 먼저 줄고 D-day는 남음.
- 서버 인사말이 "SQLD 시험까지 17일 남았어요!"처럼 D-day와 같은 말을 하는 날이 있다(서버 문구 후속).

## 영향 범위 (Scope)
`app/lib/presentation/widgets/home/exam_dday_bar_title.dart`, `design/components/passql_brand_bar_scroll_view.dart`, `widgets/home/exam_schedule_card.dart`(삭제). 앱만 — 서버·웹은 바꾸지 않음.

## 출처 (References)
- GitHub #701 이슈 본문 「1. 시험 D-day를 상단 바로 (확정)」, 리포트 결정 기록 2
- [[ISS-0413-app-home-ui-ux-redesign]]
