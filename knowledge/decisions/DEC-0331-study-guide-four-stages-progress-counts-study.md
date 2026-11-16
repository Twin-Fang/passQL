---
type: decision
id: DEC-0331
created: 2026-11-16
reviewed: null
topics: [home, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0537-study-guide-stage-route]]", "[[ISS-0536-mock-study-final-study-guide-report]]", "[[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]]", "[[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]", "[[DEC-0305-home-next-step-no-ad-card-mock-trial]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]"]
---

# DEC-0331: 학습 가이드는 매일(개념·오늘의 세트·잠금화면) > 1단계 52회 이후 기출 > 2단계 이전 기출 > 3단계 모의고사 > 4단계 FINAL·오답률 TOP 30 순서로 안내하고, 단계 진행은 실전 응시 또는 학습 모드 완료한 회차로 센다

GitHub #1078 (이슈 본문, 로컬 설계 메모 「결정 요약」, 보고서 댓글).

## 문제 정의 (Context)
기능은 많은데 어떤 순서로 쓰면 합격하는지 안내가 없었다. 홈 첫 방문 3단계 시트와 상황별 카드 하나뿐이었다([[ISS-0537-study-guide-stage-route]]).

## 결정 (Decision)
- **순서:** 매일(개념 학습·오늘의 세트·잠금화면 문제) > 1단계 최신 개정 범위(52회 이후) 기출 복원 > 2단계 이전 회차 기출 > 3단계 모의고사(AI 새 보기) > 4단계 FINAL 회차·오답률 TOP 30 > 언제나(오답노트·즐겨찾기).
- **진행:** 회차 목록의 실전 응시 + 기기 학습 모드 완료([[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]])를 "손댄 회차"로 센다. 순수 함수 `calculateStudyGuideProgress`(52회 경계).
- **상태:** 준비 중·시작 전·진행 중(n/N 회차)·완료, 첫 미완료 단계에 "지금" 표시.
- **입구:** 홈·문제 탭·프로필. 1·2단계는 회차 목록 기출 탭(`?tab=past`)으로 바로 연다.
- 소개 사이트 `sqld/guide/passql-route/`에 같은 순서 안내.

## 검토한 대안 (Alternatives)
- 단계 구성은 이슈 본문 제안을 그대로 따랐다. 다른 순서·단계 수 비교는 논의 기록 없음.
- 진행 상태 서버 계산: 논의 기록 없음(설계 메모는 회차 목록 + 기기 진도로 계산만 적음).
- 입구: 설계 메모는 "모의고사 목록 상단, 홈 첫 방문 안내"도 적었으나 보고서의 입구는 홈·문제 탭·프로필이다. 차이의 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 기능을 순서로 묶어 다음 할 일을 보여 준다. 진행 계산은 순수 함수라 테스트로 고정(`flutter test` 포함).

**부정**
- 학습 모드 진도가 기기 저장이라 다른 기기에서는 가이드 진행이 달라 보일 수 있다(DEC-0329 결과에서 따름 — 원본에 별도 논의 기록 없음).

## 영향 범위 (Scope)
앱 학습 가이드 화면, `calculateStudyGuideProgress`, 홈·문제 탭·프로필 입구, 회차 목록 `?tab=past`. 소개 사이트 `sqld/guide/passql-route/`, SQLD 허브 공부 카드, sitemap.

## 출처 (References)
- 이슈 https://github.com/Twin-Fang/passQL/issues/1078
- 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1078#issuecomment-6904384159
- 설계 메모(로컬) `docs/superpowers/specs/2026-11-16-1084-1078-mock-study-final-guide.md`

## W4 검사
- [[DEC-0302-first-run-sheets-today-steps-notification-preview]](홈 첫 진입 환영 시트 오늘 할 일 3단계): 첫 방문 시트는 그대로 두고 가이드는 별도 화면 — 충돌 없음.
- [[DEC-0305-home-next-step-no-ad-card-mock-trial]](홈 다음에 할 일 카드): 카드 규칙은 바뀌지 않음 — 충돌 없음.
- [[DEC-0328-past-exam-rewrite-operation-rules]]: 52회 경계는 기출 복원 회차 구분(52~62회 공개, 45~51회는 개정 전 범위)과 같은 방향 — 충돌 없음.
