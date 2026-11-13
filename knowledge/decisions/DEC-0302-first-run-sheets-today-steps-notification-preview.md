---
type: decision
id: DEC-0302
created: 2026-11-13
reviewed: null
topics: [home, notification]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0511-qa-1112-ui-polish-eight]]", "[[ISS-0511-qa-1112-ui-polish-eight-report]]", "[[ISS-0491-first-run-guide-home-next-step]]", "[[ISS-0493-first-launch-push-prompt-common-sense-fixes]]", "[[DEC-0132-push-permission-pre-prompt-sheet]]", "[[DEC-0149-contextual-notification-permission-prompt]]"]
---

# DEC-0302: 홈 첫 진입 환영 시트는 "오늘 할 일 3단계"와 오늘의 세트 바로 시작 버튼으로, 이어지는 알림 권한 안내는 실제로 받는 알림의 미리보기 카드로 보여 준다

GitHub #1041 (이슈 본문 1·2번, 「시안 8건」 댓글 ①②, 완료 보고서). #945(첫 진입 소개·알림 안내)를 함께 처리.

## 문제 정의 (Context)
- 환영 시트([[ISS-0491-first-run-guide-home-next-step]])는 아이콘 3줄이 같은 무게라 무엇부터 할지 안 보였고, 크레딧 줄은 번개 아이콘이었다.
- 알림 안내 시트는 `중요한 소식을 알려 드릴까요?` + 공지·점검이 첫 줄이라 받는 이득이 안 보였다(가장 쓸모 있는 시험 일정이 마지막 줄).

## 결정 (Decision)
- **환영 시트:** `하루 10분, 이렇게 시작해요` + 번호 원을 세로 선으로 이은 3단계(오늘의 세트 5문제 > 틀리면 AI 해설 > 더 풀고 싶으면 랜덤 풀기, 크레딧은 젬 아이콘). 버튼 `오늘의 세트 시작하기`(누르면 세트로 바로) + `둘러볼게요`.
- **흐름:** 둘러보기·닫기면 기존처럼 알림 안내로 이어진다. 알림 권한을 묻는 조건과 시점([[DEC-0132-push-permission-pre-prompt-sheet]], [[DEC-0149-contextual-notification-permission-prompt]], #980 첫 실행 흐름)은 그대로.
- **알림 안내:** 제목 `시험 접수일, 놓치지 않게 알려 드릴까요?` + 실제 알림 모양 카드 2개(원서접수 마감 D-1, 신고 처리 결과) + 보내는 종류 한 줄(시험 일정·신고 처리 결과·점검 안내). 광고·마케팅 표현 없음.
- **미리보기 문구:** 서버 알림 규칙·신고 처리 문구를 그대로 옮긴 사본(`NotificationPermissionTexts.previewNotifications`). 서버 문구를 바꾸면 함께 바꾼다.

## 검토한 대안 (Alternatives)
- 환영 A안 기능 카드 3개: 보기 좋지만 순서가 없어 첫 행동을 여전히 고르게 함(시안 댓글 이미지 설명).
- 알림 A안 문구만 구체적으로: 작업은 적지만 글자만이라 어떤 알림인지 상상해야 함(시안 댓글 이미지 설명).
- 채택은 사용자 위임에 따른 추천안 바로 구현, 사후 확인(이슈 본문). 사용자 확인 결과는 아직 없음.

## 결과 (Consequences)
**긍정**
- 첫 행동(오늘의 세트)이 1번과 버튼에 함께 보이고, 받는 알림 모양으로 이득이 바로 보인다(시안 댓글 추천 이유).

**부정**
- 미리보기 문구가 서버 문구의 손 사본이라 어긋날 수 있다(리포트 주의사항).
- 실기기 확인 전(시뮬레이터 실측 못 함).

## 영향 범위 (Scope)
앱 홈 환영 안내 시트, 알림 권한 안내 시트, `NotificationPermissionTexts`, 잠금화면 소개·온보딩 4장의 크레딧 아이콘.

## 출처 (References)
- GitHub #1041 이슈 본문, 시안 댓글 ①②, 완료 보고서 댓글, PR #1042
- [[ISS-0511-qa-1112-ui-polish-eight-report]]
