---
type: decision
id: DEC-0175
created: 2026-10-26
reviewed: null
topics: ["billing"]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0374-admin-subscription-revenue-dashboard]]", "[[ISS-0374-admin-subscription-revenue-dashboard-report]]"]
---

# DEC-0175: 구매 기록 금액은 레포 상수가 아니라 스토어 실결제액으로 저장하고, 금액 조회 실패는 구매 확인을 막지 않는다(NULL 저장)

GitHub #619 (원본: 2026-10-26 완료 리포트 「핵심 구현」).

## 문제 정의 (Context)
관리자 구독·매출 현황을 만들었지만 구매 기록 코드가 금액·통화를 저장하지 않아 매출이 항상 0이었다.

## 결정 (Decision)
- 구매 기록의 금액·통화는 스토어가 알려 준 실제 결제액을 저장한다(iOS: 서명 검증된 거래의 price·currency, Android: Play 주문 조회 total). 저장 단위는 x 1,000,000(`StorePrice.java`).
- 금액 조회가 실패해도 구매 확인은 막지 않는다. 금액은 NULL로 저장하고 집계에서 "금액 미기록"으로 따로 센다.

## 검토한 대안 (Alternatives)
- 가격을 레포에 상수로 두기: 버림. 리포트가 밝힌 이유 — "스토어 가격·할인·세금이 바뀌어도 실제 결제액이 그대로 남게 하기 위해서".
- 금액 조회 실패 시 구매 확인을 막기: 버림. 리포트가 밝힌 이유 — "결제한 회원이 이용권을 못 받는 것이 더 큰 문제이기 때문".

## 결과 (Consequences)
**긍정**
- 스토어 가격·할인·세금이 바뀌어도 실제 결제액이 남는다(원본 표현).

**부정**
- Android 금액은 Play 서비스 계정에 "재무 데이터 보기" 권한이 없으면 NULL로 남는다.
- 이미 쌓인 구매 행은 비어 있는 그대로다.

## 영향 범위 (Scope)
서버 결제 모듈: `StorePrice`, `AppStoreTransaction`, `AppleAppStoreSignedDataVerifier`, `AppStoreBillingService`, `PlayDeveloperApiClient`, `GooglePlayDeveloperApiClient`, `PlayBillingService`, `StorePurchaseRecorder`, `EntitlementPurchaseRepository`. 관리자 구독·매출 집계.

## 출처 (References)
- GitHub #619 완료 리포트 댓글(2026-10-26, PR #665, 릴리스 #666)
- [[ISS-0374-admin-subscription-revenue-dashboard]]
