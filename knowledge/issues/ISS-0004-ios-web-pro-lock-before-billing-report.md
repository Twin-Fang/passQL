---
type: completion-report
id: ISS-0004
created: 2026-10-23
topics: [billing]
status: resolved
resolves: "[[ISS-0004-ios-web-pro-lock-before-billing]]"
related: ["[[DEC-0006-ios-non-renewing-web-no-purchase]]", "[[DEC-0007-hold-pass-review-until-switch-on]]"]
source: "https://github.com/Twin-Fang/passQL/issues/578"
---

# ISS-0004 완료 리포트: iOS 비갱신 구독 결제와 iOS·웹 잠금 화면

GitHub #578 리포트 댓글과 정정 댓글 기준. main 병합(PR #594)·배포(PR #595).

## 해결 방법
- App Store Connect: `pro_pass_3m`(₩9,900), `pro_pass_1m`(₩4,400) 비갱신 구독, 한국. 서버 알림 V2 URL `<API 서버>/api/billing/app-store/notifications`. 유료 앱 계약 활성(2026-10-22 ~ 2027-08-12).
- 서버: StoreKit 2 거래를 `POST /billing/app-store/verify`로 검증(Apple 공식 `app-store-server-library` 5.2.0, 운영 > 샌드박스 순). `PlayPurchaseRecorder`를 스토어 공통 `StorePurchaseRecorder`로. App Store 알림 REFUND·REVOKE면 구매 회수 + 남은 구매 재생.
- 앱: `AppStorePurchaseService`, 서버 확인 뒤에만 거래 완료, 미완료 거래는 시작·복귀·복원 때 재전송.
- 웹: `useMemberPlan`, `lib/proAccess.ts`, `components/pro/`. 결제 없이 "앱에서 이용권 구매" 안내.

## 근본 원인 (확정)
iOS·웹에 잠금·구매 경로 부재.

## 재발 방지
- 결제 스위치는 계정 기준 하나라 켜는 순간 iOS에도 잠금이 뜬다 → 이용권 심사 통과 뒤에 켤 것.
- Play verify에는 스위치 검사가 없고 App Store verify에만 있다(#576 동작 유지).
- `REFUND_REVERSED`는 등급을 되살리지 않고 로그만 남긴다.
- 서명 성공 경로는 실거래 샘플이 없어 미검증(#596).

## 교훈
- 이용권 심사 제출은 취소했다(스위치가 꺼져 있으면 심사자가 구매 화면에 도달하지 못해 가이드라인 2.1 반려 위험). 상품은 "개발자가 취소함"으로 보존, 스위치를 켤 버전과 함께 제출(#596).
- 로컬 Xcode 16.2로 iOS 빌드 불가, CI 빌드만 사용.
