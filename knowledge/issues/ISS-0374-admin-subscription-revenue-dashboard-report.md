---
type: completion-report
id: ISS-0374
created: 2026-10-26
topics: ["admin", "billing"]
status: resolved
resolves: "[[ISS-0374-admin-subscription-revenue-dashboard]]"
related: ["[[DEC-0175-record-store-paid-amount-nonblocking]]"]
source: "https://github.com/Twin-Fang/passQL/issues/619"
---

# ISS-0374 완료 리포트: 스토어가 알려 준 실결제액을 구매 기록에 저장

GitHub #619 완료 리포트 댓글(2026-10-26) 기준. PR #665, 릴리스 #666.

## 해결 방법
- `StorePrice.java`(신규): 스토어 금액 > 저장 단위(x 1,000,000) 변환.
- iOS: `AppStoreTransaction`, `AppleAppStoreSignedDataVerifier`, `AppStoreBillingService`에서 서명 검증된 거래의 price·currency 전달.
- Android: `PlayDeveloperApiClient`, `GooglePlayDeveloperApiClient`, `PlayBillingService`에서 Play 주문 조회 total 사용. 조회 실패 시 금액 NULL, 구매 확인은 계속.
- `StorePurchaseRecorder`, `EntitlementPurchaseRepository`: INSERT에 금액·통화 추가.
- 테스트: billing 45건, Postgres 저장소 3건 추가·통과.

## 근본 원인 (확정)
실제 구매를 기록하는 코드가 금액·통화 값을 저장하지 않았다.

## 재발 방지
- 금액 미기록 건은 NULL로 저장되고 집계에서 "금액 미기록"으로 따로 센다.
- Android 금액은 Play 서비스 계정에 "재무 데이터 보기" 권한이 있어야 받아진다. 없으면 서버 로그 `[billing] play order price unavailable : ... reason=403`, 금액 NULL.
- 이미 쌓인 구매 행은 비어 있는 그대로(결제가 꺼져 있어 실제 결제 건 없음).
- 운영 배포 후 서버 상태 `UP` 확인. 실제 결제로 저장되는지는 결제를 켠 뒤 첫 구매에서 확인(GitHub #596).

## 교훈
(원본에 없음, 볼트 정리) 매출 현황이 0이거나 금액이 비면 먼저 서버 로그의 `play order price unavailable`(Play 서비스 계정 재무 데이터 권한)과 구매 행의 금액 NULL 여부를 본다.
