---
type: issue
id: ISS-0509
created: 2026-11-12
topics: [billing, admin]
symptoms: ["App Store 환불 미반영", "환불 메일 수신 VERIFIED 유지", "실수령액 안 보임", "애플 알림 수신 기록 없음", "CONSUMPTION_REQUEST", "REFUND 알림 미수신", "AppStoreRefundCheckService", "APP_STORE_IAP", "billing_refund_check_run"]
root_cause: "App Store 환불 반영이 애플 서버 알림(V2)에만 의존해 서버가 직접 확인할 경로가 없었고, 관리자에 건별 결제·실수령액·알림 수신 기록 화면이 없었다"
status: resolved
resolution: "[[ISS-0509-admin-billing-payout-app-store-refund-check-report]]"
related: ["[[DEC-0296-payout-estimate-krw-vat-fee-settings]]", "[[DEC-0297-app-store-consumption-response-default-off]]", "[[DEC-0298-app-store-iap-key-separate-secret]]", "[[ISS-0374-admin-subscription-revenue-dashboard]]", "[[DEC-0273-maintenance-mode-passes-external-callbacks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1032"
---

# ISS-0509: 관리자 결제 관리 — 실수령액·전체 결제 목록·App Store 환불 점검

GitHub #1032. 원본 사본: `_sources/issues/ISS-0509-admin-billing-payout-app-store-refund-check.md`(로컬).

## 증상
- 11/11 App Store 구매 > 환불 메일 수신, 서버는 VERIFIED 유지.
- App Store 환불은 애플 서버 알림(V2)에만 의존, 서버가 직접 확인하는 경로 없음.
- Play는 매일 04:50 환불 점검이 있지만 건별 결제를 한 표로 볼 화면이 없음. 매출 요약은 판매 금액뿐. 애플 알림 수신 기록이 남지 않음.

## 재현 조건
App Store 환불 알림을 서버가 받지 못하거나 Apple이 환불을 확정하기 전.

## 조사 기록
- 2026-11-12: PR #1033(a856a34d), 배포 #1034.
- 2026-11-12: 운영 원인 분석 — 애플 알림은 정상 수신(CONSUMPTION_REQUEST 3회), REFUND 알림 미수신. 환불 점검 수동 실행 결과 대상 1건이 Apple 기준 미환불(회수 0).

## 근본 원인
서버 측 환불 확인 경로·알림 기록 부재. 계기 사례 자체는 운영 시점에 Apple 기준 미환불 상태였다(REFUND 미수신과 일치).
