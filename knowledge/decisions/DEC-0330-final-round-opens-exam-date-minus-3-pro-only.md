---
type: decision
id: DEC-0330
created: 2026-11-16
reviewed: null
topics: [practice, billing, notification, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0536-mock-exam-study-mode-final-round]]", "[[ISS-0536-mock-study-final-study-guide-report]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]", "[[DEC-0293-exam-schedule-rule-based-auto-sync]]", "[[DEC-0131-member-notification-inbox-single-entry]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]"]
---

# DEC-0330: FINAL 회차는 대상 시험일 3일 전부터 열리고(그 전엔 공개 상태여도 숨김·시작 불가) 지난 FINAL은 계속 열리며, PRO 전용이고, 공개하면 여는 날 09:00 전체 회원 푸시를 예약한다

GitHub #1084 (이슈 본문, 로컬 설계 메모 「결정 요약」, 보고서 댓글).

## 문제 정의 (Context)
시험 직전에 마지막으로 점검할 특별 회차가 없었다(회차 상태는 DRAFT, PUBLISHED뿐 — [[ISS-0536-mock-exam-study-mode-final-round]]). 이슈는 "시험 3일 전 공개되는 고난도·신유형 1회분, 지난 FINAL 다시 열기, 공개 시점에 푸시"를 제안했다.

## 결정 (Decision)
- **구분:** 회차 종류 `FINAL` 추가(`MockExamRoundType.FINAL`), `examDate` = 대상 시험일. 관리자 `POST /admin/api/mock-exams/final-rounds`로 만들고 기출 회차와 같은 50문항 구성 검증.
- **공개 시점:** 여는 날 = 시험일 - 3일(`MockExamFinalRoundSchedule`). 그 전에는 공개(PUBLISHED) 상태여도 목록에서 숨기고 응시 시작도 `MOCK_EXAM_ROUND_NOT_FOUND`. 시험일 없는 FINAL은 숨김.
- **지난 FINAL:** 계속 보이고 다시 열 수 있다.
- **접근:** PRO 전용(무료 체험·무료 기출 대상 아님).
- **알림:** 공개(publish) 시 여는 날 09:00 KST 전체 회원 푸시 예약(이미 열렸으면 즉시), 링크 `MOCK_EXAM`. 여는 날이 90일 넘게 남으면 예약을 건너뛰고, 예약 실패해도 공개는 유지.

## 검토한 대안 (Alternatives)
- 공개 시점 기준: 이슈 본문은 "시험 일정 자동 수집 데이터로 공개 시점을 정한다"고 제안했으나 구현은 FINAL 회차에 넣는 대상 시험일(`examDate`) 기준이다. 바꾼 이유는 논의 기록 없음.
- 3일 전·09:00·90일 한도를 고른 이유, PRO 전용으로 정한 이유: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 시험 직전 공개를 서버가 날짜로 판정해 운영자는 미리 공개만 해 두면 된다(보고서 흐름도). 공개 경계는 테스트로 고정(`MockExamFinalRoundScheduleTest`).

**부정**
- FINAL 문항은 아직 없다 — 다음 시험 일정이 정해지면 관리자가 50문항을 구성·공개해야 한다(운영 작업).
- 공개가 여는 날보다 90일 넘게 앞서면 알림이 예약되지 않는다.
- 구버전 앱은 FINAL을 일반 모의고사 행으로 보여 준다.

## 영향 범위 (Scope)
서버 `MockExamRoundType`, `MockExamFinalRoundSchedule`, 모의고사 공개 API(목록·응시 시작), 관리자 `final-rounds`·공개 API(`AdminMockExamPublishResult`, `createFixedRound`), `AdminFinalRoundPushService`, `PushLinkTarget.MOCK_EXAM`(앱 `push_link.dart`와 1:1), `MockExamPastRoundRule`(FINAL에도 적용), `api-contract/openapi.json`. 앱 모의고사 탭 FINAL 구역.

## 출처 (References)
- 이슈 https://github.com/Twin-Fang/passQL/issues/1084
- 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1084#issuecomment-6904383937
- 설계 메모(로컬) `docs/superpowers/specs/2026-11-16-1084-1078-mock-study-final-guide.md`

## W4 검사
- [[DEC-0264-mock-exam-fixed-rounds-server-judged]](관리자 고정 회차·공개 검사, 무료 체험은 공개 회차 중 가장 작은 번호 1회): FINAL도 관리자 고정 회차·공개 흐름을 따른다. 무료 체험 대상에서 FINAL만 빼는 범위 한정이라 **조건부 공존**, 대체하지 않음.
- [[DEC-0328-past-exam-rewrite-operation-rules]](기출 무료 1회차): FINAL은 무료 기출 대상이 아님 — 범위가 달라 충돌 없음. 1~10번 1과목 검사(`MockExamPastRoundRule`)를 공용.
- [[DEC-0327-answer-key-highlight-exam-date-plus-7]](가채점 강조는 시험일 + 7일까지): 같은 시험일을 쓰되 기간이 다른 별도 기능 — 충돌 없음.
- [[DEC-0293-exam-schedule-rule-based-auto-sync]](시험 일정 자동 수집): FINAL 공개 시점은 자동 수집 데이터가 아니라 회차의 `examDate`를 쓴다 — 결정 충돌은 아니나 두 날짜가 어긋나지 않게 운영자가 맞춰야 한다.
- [[DEC-0131-member-notification-inbox-single-entry]]·[[DEC-0132-push-permission-pre-prompt-sheet]](범위 밖: 마케팅 푸시, 서비스 알림만): FINAL 공개 알림은 새 회차 공개 안내로 결정 충돌로 보지 않았다. 다만 PRO 전용 회차를 무료 회원 포함 전체에 알리는 점이 마케팅(광고성) 푸시에 해당하는지, 발송이 `MemberNotificationService` 입구를 거치는지는 원본에 기록이 없다 — **확인 필요**로 남긴다.
