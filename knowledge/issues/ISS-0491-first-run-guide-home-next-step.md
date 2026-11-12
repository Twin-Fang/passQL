---
type: issue
id: ISS-0491
created: 2026-11-12
topics: [home, auth-member, practice, design-system]
symptoms: ["처음 켰을 때 불친절", "차별점이 안 보임", "로그인 화면 문구", "홈에서 다음에 뭘 할지 없음", "무료 회원 추천 구간 없음", "시험 일정을 선택하고", "온보딩 첫 문제 풀기", "login_page", "home_page"]
root_cause: "첫 화면과 홈에 이 앱만의 기능과 지금 할 일이 드러나지 않았고, 무료 회원은 추천·출제 경향·공부 팁 구간이 통째로 없어 오늘의 세트 뒤에 안내가 끊겼다"
status: resolved
resolution: "[[ISS-0491-first-run-guide-home-next-step-report]]"
related: ["[[DEC-0287-credit-term-top-bar-balance]]", "[[ISS-0490-credit-term-purchase-funnel-events]]"]
source: "https://github.com/Twin-Fang/passQL/issues/975"
---

# ISS-0491: 첫 실행 안내와 홈 다음 할 일

GitHub #975.

## 증상
- 로그인 첫 화면 문구가 "SQL 자격증, 문제로 합격까지"라 직접 실행·AI 해설·AI 새 보기가 드러나지 않음.
- 홈에 지금 할 일이 없고, 무료 회원은 추천 문제·출제 경향·공부 팁 구간이 없어(프로 전용이라 요청하지 않음) 오늘의 세트를 풀면 안내가 끊김.
- 합격 준비도 문구가 "시험 일정을 선택하고"인데 일정은 관리자 공통 지정이라 선택 기능이 없음.

## 재현 조건
새로 설치한 앱, 무료 회원(결제 켜짐).

## 조사 기록
- 2026-11-12: 가입 직후 "첫 문제 풀기"는 이미 오늘의 세트(하루 5문제, 크레딧 안 씀)로 연결돼 있음. 다음 할 일 판정(`AiAnalysisPlanner`)은 프로 전용 AI 분석과 모의고사 결과 안에만 있음. 준비도는 최소 풀이 수 조건이 없지만 범위를 곱해 5문제로는 낮게 나옴.

## 근본 원인
첫 화면과 홈에 이 앱만의 기능과 지금 할 일이 드러나지 않았고, 무료 회원은 안내 구간이 통째로 없었다.
