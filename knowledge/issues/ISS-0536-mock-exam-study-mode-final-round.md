---
type: issue
id: ISS-0536
created: 2026-11-16
topics: [practice, billing, notification, admin]
symptoms: ["모의고사 학습 모드", "한 문제씩 정답 해설", "실전 모드만 있음", "mock_exam_solving_page", "study-questions", "/api/mock-exams/rounds/{roundUuid}/study-questions", "canStudy", "MockExamStudyFlow", "MockExamStudyProgressStore", "onQuestionAnswered", "학습 진도 기기 저장", "FINAL 회차", "MockExamRoundType.FINAL", "MockExamFinalRoundSchedule", "시험 3일 전 공개", "final-rounds", "/admin/api/mock-exams/final-rounds", "AdminFinalRoundPushService", "AdminMockExamPublishResult", "PushLinkTarget.MOCK_EXAM", "MOCK_EXAM_ROUND_NOT_FOUND", "averageDifficulty", "회차 난이도 표시"]
root_cause: "모의고사가 시간 제한 실전 모드뿐이라 한 문제씩 정답·해설을 보며 공부할 수 없었고, 회차 상태가 DRAFT·PUBLISHED뿐이라 시험 직전 특별 회차가 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0536-mock-study-final-study-guide-report]]"
related: ["[[ISS-0537-study-guide-stage-route]]", "[[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]]", "[[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0528-wrong-note-subject-filter-retry-set]]"]
source: "_sources/issues/ISS-0536-mock-exam-study-mode-final-round.md"
---

# ISS-0536: 모의고사 학습 모드와 시험 직전 FINAL 회차

GitHub #1084 (보고서 게시 시점 열림, 작업중). 원본: https://github.com/Twin-Fang/passQL/issues/1084 · 학습 가이드(#1078)와 보고서 1개를 공유: https://github.com/Twin-Fang/passQL/issues/1084#issuecomment-6904383937 · PR #1129, 릴리스 PR #1130

## 증상
- 모의고사는 실전 모드만 있어 한 문제씩 정답·해설을 바로 보며 공부할 수 없었다(`mock_exam_solving_page.dart`).
- 시험 직전에 마지막으로 점검할 특별 회차가 없었다(회차 상태는 DRAFT, PUBLISHED뿐).
- 회차 난이도를 목록에서 알 수 없었다(이슈 제안 "난이도별 회차 표시").

## 재현 조건
앱 모의고사 탭 > 회차 > 시험 안내. 시작하면 시간 제한 실전 응시로만 들어간다.

## 조사 기록
- 2026-11-14: 이슈 등록. 제안 — 학습 모드(바로 정답·해설·실행 결과 비교, 진도 저장), FINAL 모의고사(시험 3일 전 공개, 고난도·신유형 1회분, 지난 FINAL 다시 열기, 시험 일정 자동 수집 데이터로 공개 시점·푸시), 난이도별 회차 표시.
- 2026-11-16: 설계(로컬 설계 메모) — 학습 모드는 기존 `QuestionFlow` 재사용·응시 기록 없음·기기 진도([[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]]), FINAL은 대상 시험일 - 3일 공개·PRO 전용·공개 시 09:00 푸시 예약([[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]). 공개 시점은 이슈 제안(시험 일정 자동 수집)과 달리 FINAL 회차에 관리자가 넣는 대상 시험일(`examDate`) 기준.
- 2026-11-16: 구현·배포 — PR #1129 > 릴리스 PR #1130. 난이도는 회차 문항 평균(`averageDifficulty`)을 앱이 쉬움·보통·어려움으로 표시. 운영 새 경로 응답 확인(비로그인 401).

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0536-mock-study-final-study-guide-report]]. 남은 운영 작업: FINAL 문항 50개 구성·공개(다음 시험 일정 확정 후), 학습 진도 서버 저장은 후속.
