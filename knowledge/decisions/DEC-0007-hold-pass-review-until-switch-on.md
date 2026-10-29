---
type: decision
id: DEC-0007
created: 2026-10-23
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0004-ios-web-pro-lock-before-billing]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[ISS-0361-billing-switch-final-checks]]"]
---

# DEC-0007: iOS 이용권 심사는 결제 스위치를 켤 버전과 함께 제출한다

## 문제 정의 (Context)
iOS 1.40.0과 이용권 2개를 함께 심사에 냈는데, 결제 스위치가 꺼져 있으면 심사자가 앱에서 이용권 구매 화면에 도달할 수 없다 (GitHub #578 정정 댓글, 2026-10-23 16:21).

## 결정 (Decision)
이용권 제출을 취소하고 iOS 1.40.0만 다시 제출. 심사 메모의 결제 문장을 "앱 내 결제: 이번 버전에서는 사용하지 않습니다 (서버 설정으로 꺼져 있어 구매 화면이 나타나지 않습니다)."로 고침. 이용권 `pro_pass_3m`·`pro_pass_1m`은 "개발자가 취소함" 상태로 가격·현지화·심사 정보 보존, 스위치를 켤 버전과 함께 제출(#596).

## 검토한 대안 (Alternatives)
- 앱과 이용권을 함께 제출: 앱 안에서 찾을 수 없는 구매 상품으로 반려될 위험(가이드라인 2.1)이 커서 버림.

## 결과 (Consequences)
**긍정**
- 심사 반려 위험 회피.

**부정**
- 스위치를 켜는 시점에 이용권 심사를 따로 기다려야 한다.

## 영향 범위 (Scope)
App Store Connect 제출 절차, 심사 메모.

## 출처 (References)
- GitHub #578 댓글 "정정: 이용권 심사 제출 보류 (2026-10-23 16:21)"
