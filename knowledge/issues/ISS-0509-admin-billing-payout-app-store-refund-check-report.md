---
type: completion-report
id: ISS-0509
created: 2026-11-12
topics: [billing, admin]
status: resolved
resolves: "[[ISS-0509-admin-billing-payout-app-store-refund-check]]"
related: ["[[DEC-0296-payout-estimate-krw-vat-fee-settings]]", "[[DEC-0297-app-store-consumption-response-default-off]]", "[[DEC-0298-app-store-iap-key-separate-secret]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1032"
---

# ISS-0509 완료 리포트: 결제 관리 탭 5개, App Store 환불 점검 운영 가동

## 해결 방법
- `/admin/subscriptions` > 결제 관리 탭 5개(실수령액, 결제 목록, 환불 점검, 알림 기록, 기존 요약).
- 실수령액 `StorePayoutCalculator`: 판매 − 환불 = 순매출 > 원화 부가세 제외 > 스토어 수수료 제외. 수수료율·부가세율은 설정값.
- 전체 결제 목록: 필터·CSV·건별 회수, `entitlement_purchase.revoked_at`.
- App Store 환불 점검 `AppStoreRefundCheckService`: 최근 180일 검증 구매 > App Store Server API 거래 조회(운영 404면 샌드박스) > `revocationDate` 있으면 회수. 매일 04:55·수동, 실행 기록 `billing_refund_check_run`(store 구분).
- 알림 기록 `app_store_notification_log`(서명 원문·개인정보 저장 안 함), 환불 요청 CONSUMPTION_REQUEST 접수 표시, 소비 정보 자동 응답 설정(기본 꺼짐).
- Flyway `V1_114_2`, 배포 워크플로가 GitHub Secret `APP_STORE_IAP_*` 3개를 컨테이너에 연결(없으면 점검 건너뜀).
- PR #1033, 배포 #1034. 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1032#issuecomment-6825820372

## 근본 원인 (확정)
서버 측 환불 확인·알림 기록 부재. 계기 사례는 Apple 기준 미환불(REFUND 미수신)이라 알림 주소 문제는 아니었다.

## 재발 방지
- 매일 점검이 알림 누락 안전망. 운영 실측: 서버 로그 `app store server api : configured=true`, 수동 점검 성공(대상 1건, 회수 0), 실수령 전체 기간 6,800원(판매 13,200 / 환불 4,400 / 부가세 800 / 수수료 1,200).
- 검증: server build(`AppStoreRefundCheckServiceTest`, `StorePayoutCalculatorTest`), 로컬 관리자 화면·건별 회수.

## 교훈
- 환불 미반영을 보면 먼저 알림 기록에서 REFUND 수신 여부와 환불 점검 결과(Apple `revocationDate`)를 본다. 환불 메일만으로 Apple 확정을 단정하지 않는다.
- 실수령액은 추정치다. 정산서와 맞춰 설정값을 조정한다.
