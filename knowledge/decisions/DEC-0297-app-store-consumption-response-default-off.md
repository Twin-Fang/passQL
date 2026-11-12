---
type: decision
id: DEC-0297
created: 2026-11-12
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0509-admin-billing-payout-app-store-refund-check]]"]
---

# DEC-0297: App Store 환불 요청(CONSUMPTION_REQUEST)에 대한 소비 정보 자동 응답은 기본 꺼짐 — 접수 기록만 하고, 고객 동의 장치를 확인한 뒤 켠다

GitHub #1032 (PR #1033, `AppStoreConsumptionResponder` 주석, Flyway V1_114_2 설정 설명).

## 문제 정의 (Context)
애플은 환불 요청이 오면 CONSUMPTION_REQUEST 알림을 보내고, 개발자는 소비 정보(지급 여부, 무료 체험 제공, 이용 기간 경과 비율 등)로 응답할 수 있다. 운영에서는 이 알림이 3회 수신됐다.

## 결정 (Decision)
- 설정 `billing.app_store.consumption_response_enabled` 기본 `false`: 환불 요청은 알림 기록에 접수만 남긴다.
- 켜면 지급 여부(VERIFIED), 무료 체험 제공(무료 하루 크레딧), 이용 기간 경과 비율, 고객 동의 값을 보낸다.

## 검토한 대안 (Alternatives)
- 기본 켜기: Apple 규정상 고객 동의를 받은 경우에만 보낼 수 있어 하지 않음(코드 주석). 다른 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 동의 없이 소비 정보를 보내는 규정 위반을 막는다.

**부정**
- 켜기 전에는 환불 심사에 우리 쪽 소비 정보가 반영되지 않는다.

## 영향 범위 (Scope)
`AppStoreConsumptionResponder`, `AppStoreNotificationService`, `app_store_notification_log`, 관리자 알림 기록 탭.

## 출처 (References)
- GitHub #1032, PR #1033
