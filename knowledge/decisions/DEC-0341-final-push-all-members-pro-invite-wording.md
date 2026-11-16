---
type: decision
id: DEC-0341
created: 2026-11-16
reviewed: null
topics: [notification, practice, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]", "[[DEC-0131-member-notification-inbox-single-entry]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]", "[[ISS-0540-past-exam-figure-erd-generator]]", "[[ISS-0536-mock-exam-study-mode-final-round]]"]
---

# DEC-0341: FINAL 회차 공개 알림은 전체 회원 대상을 유지하고, 문구로 PRO 응시를 권한다

GitHub #1132 (이슈 본문 "함께" 항목, 보고서 댓글, 작업 세션 사용자 발언).

## 문제 정의 (Context)
[[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]는 PRO 전용 FINAL 회차를 공개하면 전체 회원에게 푸시를 예약한다. 무료 회원은 알림을 받아도 응시할 수 없어 대상을 좁힐지, 그대로 둘지 정해야 했다(DEC-0330 「W4 검사」의 확인 필요 항목).

## 결정 (Decision)
- 알림 대상은 전체 회원 그대로 둔다.
- 알림 문구로 PRO 로 응시하라고 권한다.
- 사용자 발언(작업 세션): "보내도 되지만 pro 유도하면 되지".

## 검토한 대안 (Alternatives)
- 대상을 PRO 회원으로 좁히기: 사용자 발언으로 택하지 않음("보내도 되지만"). 그 밖의 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 무료 회원에게도 FINAL 존재를 알리고 PRO 전환을 권한다.

**부정**
- PRO 권유 문구가 들어가 광고성(마케팅) 푸시로 볼 여지가 커졌다. 별도 수신 동의 필요 여부는 논의 기록 없음(아래 W4).

## 영향 범위 (Scope)
서버 `AdminFinalRoundPushService` 알림 문구. 대상·예약 시각(여는 날 09:00 KST)·링크 `MOCK_EXAM` 은 DEC-0330 그대로.

## 출처 (References)
- 이슈 https://github.com/Twin-Fang/passQL/issues/1132
- 보고서 https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6908908562

## W4 검사
- [[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]](active): 대상(전체 회원)을 그대로 두고 문구만 더하는 **보완** — 대체하지 않음, DEC-0330 은 바꾸지 않았다. DEC-0330 「W4 검사」의 확인 필요 항목 중 "PRO 전용 회차를 무료 회원 포함 전체에 알리는 것"은 사용자가 대상 유지를 직접 정해 해소됐다.
- [[DEC-0131-member-notification-inbox-single-entry]]·[[DEC-0132-push-permission-pre-prompt-sheet]](범위 밖: 마케팅 푸시, 별도 동의 필요): PRO 권유 문구를 넣은 FINAL 알림이 마케팅(광고성) 푸시에 해당하는지, 발송이 `MemberNotificationService` 입구를 거치는지는 여전히 원본에 기록이 없다 — **확인 필요**로 남긴다(DEC-0330 의 같은 항목이 이어짐).
