---
type: decision
id: DEC-0166
created: 2026-10-21
reviewed: null
topics: [home, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0356-home-questions-tab-restructure]]", "[[ISS-0356-home-questions-tab-restructure-report]]"]
---

# DEC-0166: 탭마다 역할 하나 — 홈은 읽을 것, 문제 탭은 풀 것 전부, 설정은 설정만 (출제 경향 전용 화면 폐지)

## 문제 정의 (Context)
홈의 한 줄 출제 경향 카드 뒤에 정보가 한 화면에 몰려 있었고, 오답 노트가 설정 탭에 숨어 있었다 (GitHub #574).

## 결정 (Decision)
- 이슈 본문: "탭마다 역할을 하나씩 둔다: 홈은 오늘 볼 것, 문제 탭은 풀 것 전부, 설정은 설정만."
- 홈: 출제 경향 강조 섹션(이후 넘김 카드)과 오늘의 공부 팁.
- 문제 탭: 세그먼트 `주제별` / `최신 경향` / `개념 TOP 10`, 공통 영역에 오답 노트와 풀이 모드(연습/실전).
- 설정: '기록' 묶음(오답 노트) 제거.
- 출제 경향 전용 화면은 없애고 `/exam-trend`는 문제 탭 `최신 경향`으로 리다이렉트.
- 서버와 웹은 바꾸지 않는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 홈 '전체', 옛 `/exam-trend`, 알림 링크가 모두 URL 기반으로 같은 세그먼트를 연다(리포트).

**부정**
- `QuestionsTabView.queryValue`(`latestTrend`, `concepts`)는 외부 링크 값이라 이름을 바꾸면 옛 링크가 `주제별`로 떨어진다.
- 웹(`client/`) 출제 경향 화면은 그대로 남아 앱과 구성이 다르다.

## 영향 범위 (Scope)
`app/lib/router/questions_tab_view.dart`, `app_routes.dart`, `app_router.dart`, `topic_list_page.dart`, `home_page.dart`, `settings_page.dart`, `exam_trend_providers.dart`, 삭제된 `exam_trend_page.dart`·`exam_trend_entry_card.dart`.

## 출처 (References)
- GitHub #574 이슈 본문, 리포트 댓글(2026-10-21)
- [[ISS-0356-home-questions-tab-restructure]]
