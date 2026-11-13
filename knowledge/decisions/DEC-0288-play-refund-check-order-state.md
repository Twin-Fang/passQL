---
type: decision
id: DEC-0288
created: 2026-11-12
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0494-play-refund-without-revoke-not-reclaimed]]"]
---

# DEC-0288: Play 환불 회수는 취소 목록 + 프로 유효 회원 주문 상태로 확인

## 결정
매일 환불 회수 확인은 취소 구매 목록(30일)에 더해, 지금 PRO가 유효한 회원의 검증된 Play 구매 주문 상태를 `orders.batchget`으로 확인해 전액 환불(`REFUNDED`)이면 회수한다. 실행마다 기록을 남기고 관리자 화면·관제소에서 본다.

## 배경
권한 회수 없이 한 환불은 취소 목록에 나오지 않아 PRO 기간이 남았다(#984).

## 대안
- 구매일 기준 180일 고정 기간 → 버림: 이어 산 구매가 길면 오래된 구매도 만료일에 기여, 숫자 근거 없음. 사용자 요청으로 데이터 기준(프로 유효 회원)으로.
- Play 실시간 알림(Pub/Sub) → 이번에는 보류: Google Cloud 설정이 필요. 논의 기록 없음(추후 과제).

## 결과
- 부분 환불은 회수하지 않는다.
- 관리자 「지금 확인」으로 즉시 반영 가능.

## 영향 범위
`PlayRefundCheckService`, `PlayVoidedPurchaseScheduler`, `billing_refund_check_run`, 관리자 구독·매출 현황, 관제소 `billing.refund_check_failed`.
