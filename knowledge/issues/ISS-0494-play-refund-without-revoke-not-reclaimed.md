---
type: issue
id: ISS-0494
created: 2026-11-12
topics: [billing, admin]
symptoms: ["환불했는데 PRO 그대로", "voided=0", "voidedpurchases", "권한 회수 없이 환불", "revoke 없이 환불", "service account not configured", "PlayVoidedPurchaseScheduler"]
root_cause: "Play 취소 구매 목록 API는 권한 회수(revoke) 없이 한 환불을 돌려주지 않는데, 서버 환불 회수는 그 목록만 봤다"
status: resolved
resolution: "[[ISS-0494-play-refund-without-revoke-not-reclaimed-report]]"
related: ["[[ISS-0485-billing-test-setup-e2e]]", "[[DEC-0288-play-refund-check-order-state]]"]
source: "https://github.com/Twin-Fang/passQL/issues/984"
---

# ISS-0494: Play 환불이 권한 회수 없이 처리되면 PRO 기간이 회수되지 않음

GitHub #984.

## 증상
- 2026-11-11 23:50 KST Play Console에서 1개월권 1건 환불. 11-12 04:50 회수 확인 로그 `voided=0, revoked=0`, 회원 만료일 두 달치(2027-01-10) 유지.
- 11-09~11-11 은 `voided purchase check skipped : service account not configured` (서비스 계정 키 미설정).

## 재현 조건
Play Console 주문 관리에서 '권한 회수' 체크 없이 환불.

## 근본 원인
Google 문서: "If a developer refunds a purchase without setting the revoke option, the order will not be returned by the API." 서버는 취소 구매 목록만 봤다.
