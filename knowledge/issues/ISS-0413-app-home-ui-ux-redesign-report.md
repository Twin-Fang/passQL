---
type: completion-report
id: ISS-0413
created: 2026-10-27
topics: [home, design-system]
status: resolved
resolves: "[[ISS-0413-app-home-ui-ux-redesign]]"
related: ["[[DEC-0189-home-section-layout-single-cta]]", "[[DEC-0190-exam-dday-in-top-bar]]", "[[DEC-0191-home-order-readiness-then-daily-set]]", "[[DEC-0192-readiness-activity-rings]]"]
source: "https://github.com/Twin-Fang/passQL/issues/701"
---

# ISS-0413 완료 리포트: 홈을 구간(면 + 회색 띠) 구조로, 준비도 → 오늘의 세트 순서

GitHub #701 리포트 댓글(2026-10-27) 기준. 이슈는 2026-10-28 닫혔다.

## 해결 방법
- 순서: 상단 바 D-day → 인사말·공지·합격 준비도(겹친 링) → 오늘의 세트 → 이번 시험 출제 경향 → 추천 문제 → 학습 현황 → 광고 → 공부 팁 → 오늘의 토론.
- 공통 컴포넌트: `passql_section.dart`·`passql_section_gap.dart`, `passql_section_header.dart`·`passql_section_link.dart`, `passql_activity_rings.dart`, `passql_marquee_text.dart` + `tokens/passql_motion.dart`, `passql_list_row.dart`(좌우 여백 끄기, 화살표 14 → 18). `.claude/rules/Design.md` 갱신.
- 상단 바: `exam_dday_bar_title.dart`(스크린리더 "시험까지 17일, ..."), `passql_brand_bar_scroll_view.dart` `leading`. 프로필 탭 설정 톱니 위치를 홈 알림 종과 맞춤.
- 홈 위젯: `daily_set_section.dart`(← `daily_set_card.dart`, 다 푼 날 정오 칸), `random_practice_row.dart`, `app_notice_banner.dart`(마퀴), `recommendations_section.dart`(행 왼쪽 정렬 버그 수정), `section_or_card.dart`, `ad_inline_card.dart` `isSection`, `exam_schedule_card.dart` 삭제.
- API 값은 하나도 빼지 않고 쓰지 않던 `results`·`lastActivityAt`·`isSolvedByMe`·`updatedDate`를 더함.
- 규칙: `ad_placement_rules_test.dart`·`app/CLAUDE.md`의 홈 광고 자리 설명을 "학습 현황 아래 구간 1개"로(개수 1개 유지).

## 근본 원인 (확정)
원본에 적혀 있지 않다.

## 재발 방지
- `PassqlSection` 위 여백은 제목 줄(44) 안 빈 공간만큼 줄여 계산(`verticalSlack`) — 제목 줄 높이·크기를 바꾸면 간격이 어긋난다.
- `PassqlListRow` 화살표 18은 홈 밖 목록 행에도 적용.
- `ReadinessCard`·`HeatmapWidget`은 통계 화면도 써서 `isSection: true`일 때만 홈 모양.
- 스켈레톤 높이(180·180·200)는 어림값.
- 확인하지 못함: 최종 라이트 모드, 기록 있는 계정의 링, 다 푼 날, 랜덤 풀기 행, 공지 마퀴, 일정 없음 상단 바, 오늘의 토론, 프로필 설정 아이콘 위치.
- 후속: 서버 인사말이 상단 바 D-day와 같은 말을 하는 날이 있음(서버 문구 이슈), 목록형 화면 구간화 검토, `latestTrendTopics` 활용, 「오늘의 순위」 참여자 수·내 순위는 API 호출 증가로 보류.
- 검증: `flutter analyze` 문제 없음, `flutter test` 52개(규칙 31개, 새 단위 4개) 통과, 시뮬레이터 다크 확인.

## 교훈
(원본에 없음, 볼트 정리) 시안에 API에 없는 값이 들어가 있지 않은지(리포트 결정 6) 구현 전에 실제 필드와 대조한다.
