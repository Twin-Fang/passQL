---
type: completion-report
id: ISS-0543
created: 2026-11-18
topics: [home, auth-member, practice]
status: resolved
resolves: "[[ISS-0543-home-welcome-sheet-only-when-daily-set-solvable]]"
related: ["[[DEC-0345-home-welcome-sheet-only-when-daily-set-solvable]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]"]
source: "_sources/issues/ISS-0543-home-welcome-sheet-only-when-daily-set-solvable-report.md"
---

# ISS-0543 완료 리포트: 환영 시트는 오늘의 세트를 풀 수 있을 때만, 버튼은 시작하기 + 나중에 (#1157)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1157#issuecomment-6975017366 · 커밋 71aa6a0c

## 해결 방법
- `HomeWelcomeGuideTrigger(canSolveDailySet: bool?)`: null(세트 정보 없음) 판정 미룸·본 것으로 기록 안 함 / false(이미 풂) 시트 없이 알림 권한 안내 / true 시트. 값은 홈 `home_page.dart` 가 「다음에 할 일」 카드와 같은 계산으로 넘김.
- 시트 버튼 `오늘의 세트 시작하기` + `나중에`, SQLD 알아보기 버튼 제거(입구는 시험 일정 화면). 결정은 [[DEC-0345-home-welcome-sheet-only-when-daily-set-solvable]].

## 근본 원인 (확정)
표시 조건이 홈 첫 방문 여부뿐이었고, 버튼 구성이 다른 안내 시트와 달랐다.

## 재발 방지
- 검증: `flutter analyze` 무이슈, architecture·presentation 테스트 117개 통과, 실제 위젯 렌더 라이트·다크·SE 캡처. 시뮬레이터 실측은 호스트 메모리 부족으로 못 함(앱 빌드로 확인 필요).
- 첫 실행에 띄우는 시트는 온보딩이 이미 한 행동과 겹치지 않는지 함께 본다.

## 교훈
첫 진입 안내를 고칠 때는 버튼 모양보다 먼저 온보딩 > 첫 문제 > 결과 > 홈 전체 흐름에서 같은 권유가 반복되는지 확인한다.
