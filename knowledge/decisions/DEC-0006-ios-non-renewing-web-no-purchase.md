---
type: decision
id: DEC-0006
created: 2026-10-23
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0004-ios-web-pro-lock-before-billing]]"]
---

# DEC-0006: iOS는 App Store 비갱신 구독으로 판매, 웹은 결제 없이 앱 구매 안내만

## 문제 정의 (Context)
결제 스위치를 켜면 iOS·웹에도 잠금이 적용되는데 두 곳에 구매 수단이 없었다. App Store는 앱 밖 구매 유도를 금지해 Android의 `회차 패스로 열기` 버튼을 그대로 쓸 수 없었다 (GitHub #578).

## 결정 (Decision)
- iOS: 1개월·3개월 이용권을 App Store 비갱신 구독으로 판다. 시트에 "구매는 Apple ID 계정으로 결제됩니다." 한 줄.
- 웹: 구매 없이 잠금 + "앱에서 이용권 구매" 안내 (웹 결제는 하지 않음).
- 같은 계정이 Android에서 산 프로는 iOS·웹에서도 열린다(서버 등급 기준).

## 검토한 대안 (Alternatives)
- iOS 안내만 두고 결제 없음: 이슈 본문에서 후보였으나 비갱신 구독을 붙이기로 함(선택 이유는 원본에 없음).

## 결과 (Consequences)
**긍정**
- 플랫폼과 무관하게 계정 하나로 프로가 공유된다.

**부정**
- Apple 실서명 거래 샘플이 없어 서명 성공 경로는 미검증(#596).
- `REFUND_REVERSED`는 등급을 되살리지 않는다.

## 영향 범위 (Scope)
서버 `/billing/app-store/verify`·App Store 서버 알림 V2, 앱 `AppStorePurchaseService`, 웹 `components/pro/`.

## 출처 (References)
- GitHub #578 이슈 본문·리포트
