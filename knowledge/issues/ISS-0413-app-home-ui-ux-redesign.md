---
type: issue
id: ISS-0413
created: 2026-10-27
topics: [home, design-system]
symptoms: ["홈 카드 위계 안 보임", "홈 화면 평평함", "시험 일정 카드", "공지 제목 잘림", "추천 문제 행 가운데 밀림", home_page.dart]
root_cause: "홈이 비슷한 카드 목록이라 지금 해야 할 일과 카드별 중요도가 드러나지 않았다"
status: resolved
resolution: "[[ISS-0413-app-home-ui-ux-redesign-report]]"
related: ["[[DEC-0189-home-section-layout-single-cta]]", "[[DEC-0190-exam-dday-in-top-bar]]", "[[DEC-0191-home-order-readiness-then-daily-set]]", "[[DEC-0192-readiness-activity-rings]]", "[[ISS-0405-home-first-load-skeleton-wait]]"]
source: "https://github.com/Twin-Fang/passQL/issues/701"
---

# ISS-0413: 앱 홈 화면 UI/UX 개편

GitHub #701 (원본: 이슈 본문과 댓글).

## 증상
홈 탭의 카드 배치와 정보 위계를 다시 짜야 했다. 기존 순서: 인사 > 공지 > 오늘의 세트 + 시험 일정 > 랜덤 풀기 > 출제 경향 > 공부 팁 > 합격 준비도 > 오늘의 토론 > 학습 현황 + 광고 > 추천 문제. 기대 결과는 "홈을 열었을 때 지금 해야 할 일이 가장 먼저 보인다", "카드마다 중요도에 맞는 크기와 강조"(이슈 본문).

## 재현 조건
해당 없음 (디자인 개편).

## 조사 기록
- 2026-10-27 이슈 본문: D-day 상단 바 이동은 확정(B안 시안 채택), 카드 순서는 논의 중. 앱만 바꾸고 서버·웹은 바꾸지 않는다. 이전 관련 GitHub #184, #648, #676.
- 2026-10-27 확정 댓글(2026-10-28 갱신): 토스식 구간 레이아웃, 9개 구간 순서, 처음 시안과 달라진 점(준비도가 세트 위로, 출제 경향이 세트 바로 아래, 순위는 제목 줄 링크, 연속 학습 일수와 준비도 제목 제외).
- 2026-10-27 리포트: 결정 기록 표 8건과 구현. 범위 밖: 출제 경향 API `latestTrendTopics`는 앱 어디에서도 쓰지 않음.

## 근본 원인
원본에 적혀 있지 않다 (디자인 개선 요청).
