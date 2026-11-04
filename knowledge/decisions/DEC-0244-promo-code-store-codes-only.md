---
type: decision
id: DEC-0244
created: 2026-11-04
reviewed: null
topics: [billing, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0448-mypage-account-pass-area-promo-code]]", "[[ISS-0448-mypage-account-pass-area-promo-code-report]]", "[[DEC-0006-ios-non-renewing-web-no-purchase]]", "[[DEC-0003-one-and-three-month-pass]]", "[[DEC-0243-profile-top-card-style-a]]"]
---

# DEC-0244: 프로모션 코드는 스토어 코드만 쓴다 (iOS App Store 오퍼 코드, Android Play 프로모 코드) — 자체 서버 코드는 만들지 않고, 운영 보상은 관리자 부여를 계속 쓴다

## 문제 정의 (Context)
문제가 생긴 사용자에게 보상할 프로모션 코드 입력이 없고 구매 복원만 있었다 (GitHub #816). 이용권은 iOS 비갱신 구독, Android 일회성 상품이다 ([[DEC-0006-ios-non-renewing-web-no-purchase]]).

## 결정 (Decision)
- **iOS:** App Store 오퍼 코드를 StoreKit 코드 입력 시트로 받는다. 2025-10부터 비갱신 구독도 오퍼 코드를 지원하고, 기존 IAP 프로모 코드는 2026-03-26부터 생성이 중단됐다. iOS 16.3+.
- **Android:** Play 프로모 코드(일회성 상품, 분기 500개)를 `https://play.google.com/redeem?code=` 링크로 Play 코드 입력 화면에서 받는다. 앱 밖에서 쓰는 경우도 있어 앱 시작 시 미처리 구매 복구 경로로 반영한다.
- **자체 서버 코드는 만들지 않는다.** App Store 심사 가이드라인 3.1.1(앱 자체 수단으로 유료 기능 열기 금지) 위험 때문이다.
- **운영 보상**은 기존 관리자 부여(운영 지급)도 계속 쓴다.
- 스토어 호출은 앱 결제 포트 계층 안에만 둔다. 코드 입력 진입점은 프로필 이용권 행과 `/account` 화면이다.

## 검토한 대안 (Alternatives)
- **자체 서버 프로모션 코드:** 가이드라인 3.1.1 위험으로 버렸다 (이슈 본문 설계자 판단).
- **iOS 기존 IAP 프로모 코드:** 2026-03-26부터 생성 중단이라 오퍼 코드를 쓴다.

## 결과 (Consequences)
**긍정**
- 심사 위험 없이 보상 수단이 생기고, 코드 발급·사용 관리는 스토어가 한다.

**부정**
- iOS는 16.3 이상에서만 코드 시트를 쓸 수 있고, Android Play 프로모 코드는 분기 500개 한도가 있다.
- iOS 코드 시트 적용 결과는 구매 스트림으로만 반영되고, Android는 앱으로 돌아올 때 갱신에 기댄다 (리포트).

## 영향 범위 (Scope)
앱 결제 포트 계층(오퍼 코드 시트·Play 코드 링크), 프로필 이용권 행(`profile_plan_action_rows.dart`), `/account` 화면. 스토어 콘솔(App Store Connect 오퍼 코드, Play Console 프로모 코드) 발급. 관리자 이용권 부여는 그대로.

## 출처 (References)
- GitHub #816 이슈 본문 「5. 프로모션 코드 = 스토어 코드 (설계자 판단)」, 리포트 「핵심 구현」 (2026-11-04)
- 이슈: [[ISS-0448-mypage-account-pass-area-promo-code]], 리포트 [[ISS-0448-mypage-account-pass-area-promo-code-report]]
