---
type: completion-report
id: ISS-0494
created: 2026-11-12
topics: [billing, admin]
status: resolved
resolves: "[[ISS-0494-play-refund-without-revoke-not-reclaimed]]"
related: ["[[DEC-0288-play-refund-check-order-state]]"]
source: "https://github.com/Twin-Fang/passQL/issues/984"
---

# ISS-0494 완료 리포트: 주문 상태 확인 추가, 실행 기록·관리자·관제소 (PR #987)

## 해결 방법
- 매일 04:50 확인(및 관리자 「지금 확인」)에 `orders.batchget` 주문 상태 확인 추가: 프로 유효 회원의 VERIFIED Play 구매 전부 > `REFUNDED` 회수. 부분 환불은 회수 안 함.
- `PlayRefundCheckService` 분리, 실행마다 `billing_refund_check_run` 1행(실행 방식, 건수, 실패 사유 종류).
- 관리자 구독·매출 현황 「환불 회수 확인」(최근 14회, 지금 확인 버튼, 감사 로그), 관제소 확인할 일(결제 켜짐 + 최근 실패 또는 26시간 성공 없음).
- 2026-11-12 13:30 운영에서 지금 확인: 확인 주문 2, 환불 1, 회수 1. `GPA.3346-4164-0890-85712` 만료 2027-01-10 → 2026-12-11.

## 근본 원인 (확정)
취소 구매 목록 API가 권한 회수 없는 환불을 빼고, 서버는 그 목록만 봤다.

## 재발 방지
- 환불 회수는 취소 목록 + 주문 상태 두 경로. 실행 기록과 관제소 경고로 미실행·실패를 바로 본다.
- 서비스 계정에 Play Console 재무 데이터 보기 권한이 빠지면 `ORDER_LOOKUP_FAILED`.

## 교훈
- 스토어 "목록" API의 포함 조건을 문서로 확인하지 않으면 운영 절차(콘솔에서 어떤 옵션으로 환불했나)에 따라 조용히 빠진다. 상태 조회 경로를 함께 둔다.
