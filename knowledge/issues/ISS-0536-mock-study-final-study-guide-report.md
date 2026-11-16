---
type: completion-report
id: ISS-0536
created: 2026-11-16
topics: [practice, home, billing, notification, admin]
status: resolved
resolves: "[[ISS-0536-mock-exam-study-mode-final-round]]"
related: ["[[ISS-0537-study-guide-stage-route]]", "[[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]]", "[[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]", "[[DEC-0331-study-guide-four-stages-progress-counts-study]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1084#issuecomment-6904383937"
---

# ISS-0536 완료 리포트: 모의고사 학습 모드·FINAL 회차(#1084) + 학습 가이드(#1078)

두 이슈가 보고서 1개를 공유한다(#1078 댓글 https://github.com/Twin-Fang/passQL/issues/1078#issuecomment-6904384159 도 같은 본문). 이 리포트가 [[ISS-0536-mock-exam-study-mode-final-round]]·[[ISS-0537-study-guide-stage-route]]를 함께 닫는다. PR #1129 > 릴리스 PR #1130.

## 해결 방법
- 학습 모드([[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]]): 서버 `GET /api/mock-exams/rounds/{roundUuid}/study-questions`(응시 기록 없음, 풀이는 문제 상세·제출 기존 경로라 크레딧도 기존 규칙), 회차 목록 `canStudy`. 앱 `MockExamStudyFlow`(기존 `QuestionFlow` 위), `QuestionFlow.onQuestionAnswered` 훅(기본 없음), `MockExamStudyProgressStore`(기기 저장 키 2개). 시험 안내 하단 [학습 모드 | 실전 시작], 실전 이어 풀기 중이면 학습 모드 버튼 숨김. 50문항 끝내면 완료 표시, 다음엔 처음부터.
- FINAL 회차([[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]): `MockExamRoundType.FINAL`, `MockExamFinalRoundSchedule`(여는 날 = 시험일 - 3일, 시험일 없는 FINAL 숨김, 지난 FINAL 계속 열림). 안 열린 FINAL은 목록 제외·응시 시작도 `MOCK_EXAM_ROUND_NOT_FOUND`. 관리자 `POST /admin/api/mock-exams/final-rounds`(기출 회차 생성 경로 공용화 `createFixedRound`, FINAL 번호는 종류별 최대 + 1). 공개 API가 `AdminMockExamPublishResult` 반환 > 새로 공개된 FINAL이면 `AdminFinalRoundPushService`가 여는 날 09:00 전체 푸시 예약(90일 넘으면 건너뜀, 실패해도 공개 유지). `PushLinkTarget.MOCK_EXAM` 추가(앱 `push_link.dart`와 1:1). 앱 모의고사 탭 FINAL 구역(없으면 "시험 3일 전에 열려요").
- 난이도: 회차 목록 `averageDifficulty`(회차 문항 평균, 회차별 GROUP BY 1회) > 앱 회차 행 둘째 줄 끝에 표시.
- 학습 가이드([[DEC-0331-study-guide-four-stages-progress-counts-study]]): `calculateStudyGuideProgress`(순수, 52회 경계) + 화면(매일 > 단계 4개 + 오답률 TOP 30 > 언제나), 상태 준비 중·시작 전·진행 중·완료, 첫 미완료 단계에 "지금" 표시. 입구 홈·문제 탭·프로필, 1·2단계는 `?tab=past`. 소개 사이트 `sqld/guide/passql-route/`, SQLD 허브 공부 카드 맨 앞, sitemap.
- 검증: 서버 전체 테스트, `OpenApiContractTest`, `MockExamFinalRoundScheduleTest`(공개 경계 3일 전, 지난 FINAL, 시험일 없음). 앱 `flutter analyze` 0, `flutter test` 191. 운영 새 서버 healthy, 새 경로 비로그인 401, 소개 사이트 새 페이지 200·sitemap 포함.

## 근본 원인 (확정)
기능 부재(모의고사 공부 방식이 실전 하나뿐, 시험 직전 회차·학습 순서 안내 없음).

## 재발 방지
- 학습 진도는 기기에만 저장된다 — 다른 기기·재설치면 처음부터(서버 저장은 후속). 진도 문의 시 먼저 확인.
- 학습 모드는 응시 기록을 만들지 않아 점수 추이·예상 합격률·순위에 들어가지 않는다. 학습 가이드에서는 학습 모드 완료도 "손댄 회차"로 센다.
- FINAL 문항은 아직 없다. 다음 시험 일정이 정해지면 관리자 API로 50문항을 구성·공개한다. 공개가 여는 날보다 90일 넘게 앞서면 알림 예약을 건너뛰므로 그 안에 공개한다.
- 구버전 앱은 FINAL 회차를 일반 모의고사 행으로 보여 준다(모르는 종류는 unknown 처리).
- `MockExamPastRoundRule`은 FINAL에도 쓰인다(1~10번 1과목 검사 같음).

## 교훈
회차 문항을 한 문제씩 보는 기능은 `QuestionFlow`에 흐름 클래스를 더해 붙인다([[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]와 같은 방식). FINAL이 목록에 안 보이면 공개 상태보다 먼저 대상 시험일(`examDate`)과 오늘 >= 시험일 - 3일인지 확인하고, 푸시가 안 왔으면 공개 시점이 여는 날 90일 이내였는지 확인한다.
