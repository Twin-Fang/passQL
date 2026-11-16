---
type: issue
id: ISS-0537
created: 2026-11-16
topics: [home, practice]
symptoms: ["학습 가이드", "추천 학습 순서", "어떤 순서로 공부", "단계별 바로가기", "home_welcome_guide", "home_next_step", "calculateStudyGuideProgress", "52회 경계", "지금 할 일", "단계 상태 준비 중 시작 전 진행 중 완료", "?tab=past", "sqld/guide/passql-route"]
root_cause: "기능은 많은데 어떤 순서로 쓰면 합격하는지 안내가 없었고, 홈 첫 방문 3단계 시트와 상황별 카드 하나뿐이었다(기능 부재)"
status: resolved
resolution: "[[ISS-0536-mock-study-final-study-guide-report]]"
related: ["[[ISS-0536-mock-exam-study-mode-final-round]]", "[[DEC-0331-study-guide-four-stages-progress-counts-study]]", "[[ISS-0491-first-run-guide-home-next-step]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]", "[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0529-hardest-questions-top30]]", "[[ISS-0534-intro-site-past-exam-preview-study-guides]]"]
source: "_sources/issues/ISS-0537-study-guide-stage-route.md"
---

# ISS-0537: 학습 가이드 — 단계별 추천 학습 순서와 바로가기

GitHub #1078 (보고서 게시 시점 열림, 작업중). 원본: https://github.com/Twin-Fang/passQL/issues/1078 · 모의고사 학습 모드·FINAL(#1084)과 보고서 1개를 공유: https://github.com/Twin-Fang/passQL/issues/1078#issuecomment-6904384159

## 증상
- 기능은 많은데 "어떤 순서로 쓰면 합격하는지" 알려 주는 안내가 없었다.
- 있는 것은 홈 첫 방문 "오늘 할 일 3단계" 시트(`home_welcome_guide.dart`)와 상황별 카드 하나를 고르는 규칙(`app/lib/core/utils/home_next_step.dart`)뿐, 개념 단원도 순서를 안내하지 않았다.

## 재현 조건
앱 전반. 신규·기존 회원 모두 기출 복원·모의고사·FINAL·오답률 TOP 30 중 무엇부터 할지 알 수 없음.

## 조사 기록
- 2026-11-14: 이슈 등록. 단계 제안 — 상시(개념·오늘의 세트·잠금화면) > 1단계 52회 이후 기출 > 2단계 이전 기출 > 3단계 모의고사(AI 새 보기) > 4단계 FINAL·오답률 TOP 30, 전 과정 오답노트·실행 결과 비교. 단계마다 진행 상태 표시, 기능 이슈가 끝나는 대로 링크 연결.
- 2026-11-16: #1084와 한 브랜치로 구현. 진행 계산은 순수 함수 `calculateStudyGuideProgress`(회차 목록 실전 응시 + 기기 학습 완료, 52회 경계), 단계 정의는 [[DEC-0331-study-guide-four-stages-progress-counts-study]]. 입구 홈·문제 탭·프로필, 1·2단계는 회차 목록 기출 탭(`?tab=past`)으로. 소개 사이트 `sqld/guide/passql-route/` 글·SQLD 허브 공부 카드 맨 앞·sitemap.
- 2026-11-16: `flutter test` 191건(진행 계산 테스트 포함), 운영 소개 사이트 새 페이지 200.

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0536-mock-study-final-study-guide-report]].
