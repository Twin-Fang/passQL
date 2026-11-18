---
type: issue
id: ISS-0543
created: 2026-11-18
topics: [home, auth-member, practice]
symptoms: ["환영 시트", "HomeWelcomeGuideTrigger", "homeWelcomeGuideSeen", "오늘의 세트 시작하기 반복", "둘러볼게요", "SQLD가 처음이라면 시험부터 알아보기", "온보딩 후 환영 시트", "첫 진입 시트 버튼 경쟁", "첫 실행 흐름 리텐션"]
root_cause: "환영 시트가 홈 첫 방문 여부만 보고 떠서 온보딩에서 세트를 푼 사람에게도 세트를 다시 권했고, 주 버튼 아래 같은 무게의 글자 버튼 2개가 첫 행동을 흐렸다"
status: resolved
resolution: "[[ISS-0543-home-welcome-sheet-only-when-daily-set-solvable-report]]"
related: ["[[DEC-0345-home-welcome-sheet-only-when-daily-set-solvable]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]", "[[ISS-0511-qa-1112-ui-polish-eight]]", "[[ISS-0521-sqld-exam-guide-and-yearly-stats]]", "[[ISS-0393-active-user-count-analysis]]"]
source: "_sources/issues/ISS-0543-home-welcome-sheet-only-when-daily-set-solvable.md"
---

# ISS-0543: 첫 진입 환영 시트가 세트 푼 사람에게도 세트를 다시 권하고, 아래 글자 버튼 2개가 경쟁함 (#1157)

GitHub: https://github.com/Twin-Fang/passQL/issues/1157

## 증상
- 온보딩 마지막 장 `첫 문제 풀기`로 오늘의 세트를 푼 뒤 홈에 처음 오면 환영 시트가 다시 `오늘의 세트 시작하기`를 권한다.
- 주 버튼 아래 `둘러볼게요`, `SQLD가 처음이라면 시험부터 알아보기`가 같은 강조색·크기라 주 버튼과 경쟁하고, 길이가 들쭉날쭉하고 빈 공간이 크다 (사용자: "뭔가 안이쁘고 이상하거든").
- SQLD 알아보기는 첫 문제 전 다른 화면으로 빠지는 샛길. 사용자: 흐름대로 따라가면 자연스럽게 공부하게(리텐션) 해 달라고 했던 방향과 어긋남.

## 재현 조건
신규 가입 > 온보딩 3장 > 첫 문제 풀기 > 세트 > 결과 > 홈 첫 방문.

## 조사 기록
- 2026-11-18: `HomeWelcomeGuideTrigger` 가 `homeWelcomeGuideSeen` 만 확인, 온보딩(`onboarding_page.dart`)은 이미 세트로 보냄 > 중복 권유 확인. 다른 시트(잠금화면 소개, 알림 안내)는 주 버튼 + `나중에` 구조.

## 근본 원인
표시 조건에 오늘의 세트 상태가 없었고, 시트에 성격이 다른 탈출 버튼(닫기)과 샛길 링크(SQLD 안내)가 같은 모양으로 함께 있었다.
