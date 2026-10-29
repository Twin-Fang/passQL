---
type: decision
id: DEC-0003
created: 2026-10-23
reviewed: null
topics: [billing]
status: active
supersedes: DEC-0002
superseded_by: null
related: ["[[ISS-0005-replace-exam-pass-with-period-pass]]", "[[ISS-0004-ios-web-pro-lock-before-billing]]"]
---

# DEC-0003: 1개월권 ₩4,400 · 3개월권 ₩9,900 기간제 이용권 (자동 갱신 없음)

## 문제 정의 (Context)
#578(iOS·웹 잠금, iOS 결제 방식 결정) 진행 중 2026-10-23 댓글로 결제 상품 구조를 바꿨다. 대상은 #576의 회차 패스([[DEC-0002-exam-pass-until-next-sqld]])이고, 같은 댓글이 #501(월간·연간 구독, 크레딧)의 대체 여부 정리를 다음 작업으로 남겼다. 결정 댓글이 직접 밝힌 이유는 자동 갱신을 피하는 것(아래 대안)과 가격 근거(아래 결과)뿐이다.

## 결정 (Decision)
Android·iOS 공통으로 두 상품.
- 3개월권 ₩9,900, 90일, **기본 선택**, `25% 할인 · 월 3,300원` 표시 (`pro_pass_3m`)
- 1개월권 ₩4,400, 30일, 연장용 (`pro_pass_1m`)
- 기간이 끝나면 끝나는 이용권 — 자동 갱신 아님. iOS는 App Store 비갱신 구독, Android는 Play 일회성 상품(#591에서 확정).
- 만료일은 서버 계산: `max(지금, 현재 만료일) + 기간`. 남은 기간 뒤에 이어 붙인다. 시험일 기준 계산 폐기.
- 단일 구매(평생)는 하지 않는다. 무료/프로 경계는 [[DEC-0004-free-pro-feature-boundary]] 그대로.

## 검토한 대안 (Alternatives)
- 자동 갱신 구독(월간·연간, #501): 수험 기간만 쓰는 앱이라 합격 뒤 계속 청구되는 불만·환불을 피하려고 버림.
- 단일 구매(평생): 하지 않기로 함 (이유는 원본에 없음).
- 회차 패스(시험일까지): 이 결정으로 대체. 대체 이유는 결정 댓글에 따로 적혀 있지 않다(#591 이슈 본문은 시험일 기준 계산이 기간제·연장을 표현 못 한다고 적음).
- Android 선불 요금제 구독: 일회성 상품과 함께 후보였고 #591 구현에서 일회성 상품으로 정함.

## 결과 (Consequences)
**긍정**
- 3개월권을 만 원 아래로, 교재 한 권보다 싸게.
- 소규모 사업자 프로그램(15%) 기준 순수익: 3개월권 약 7,650원, 1개월권 약 3,400원.

**부정 / 조건**
- 비교 앱(가스·위험물 기출 앱 1개월 자동 갱신 ₩1,100 광고 제거, 유월드기출·이지패스 SQLD 무료) 대비 유료로 받으려면 무료 앱에 없는 가치(실행, 전체 해설, 약점 분석, 출제 경향)를 프로에 묶어야 한다.
- 관리자 부여 위에 이어 붙인 구매가 환불되면 관리자 부여분이 사라진다(#591 주의사항).

## 영향 범위 (Scope)
서버 `PassProduct`·`PassExpiryCalculator`·`entitlement_purchase.granted_days`·등급 응답 `passOptions`, Play Console·App Store Connect 상품 2개, 앱 결제 시트. 결제 스위치(`billing.android.enabled`)는 이 결정으로 켜지 않았다 — [[DEC-0005-ship-with-billing-switch-off]].

## 출처 (References)
- GitHub #578 댓글 "결제 상품 구조 변경 결정 (2026-10-23)"
- GitHub #591 이슈·리포트, #501 마지막 댓글(대체로 취소)
- [[ISS-0005-replace-exam-pass-with-period-pass]], [[ISS-0004-ios-web-pro-lock-before-billing]]
