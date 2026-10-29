---
type: completion-report
id: ISS-0005
created: 2026-10-23
topics: [billing]
status: resolved
resolves: "[[ISS-0005-replace-exam-pass-with-period-pass]]"
related: ["[[DEC-0003-one-and-three-month-pass]]"]
source: "https://github.com/Twin-Fang/passQL/issues/591"
---

# ISS-0005 완료 리포트: 기간제 이용권 2종과 만료일 이어 붙이기

GitHub #591 리포트 댓글 기준. main 병합(PR #592). 결제 스위치는 켜지 않음.

## 해결 방법
- Play Console 일회성 상품: `pro_pass_3m`(KRW 9,900), `pro_pass_1m`(KRW 4,400), 활성. 다른 국가 가격은 Play 환산값.
- 서버 `PassProduct`(PQL-Domain-Member): 상품 ID·일수 단일 원본, 선언 순서 = 결제 시트 순서(3개월 먼저).
- `PassExpiryCalculator`: `max(구매 시각, 현재 프로 만료일) + 일수`. 구매·등급 응답 미리보기·환불 재생이 같은 식. 시험일 기준 `ExamPassExpiryCalculator` 삭제.
- `entitlement_purchase.granted_days` 추가(`V1_38_0`). Play 검증은 `PassProduct`에 있는 ID만 허용(옛 `pro_exam_pass` 거부).
- 환불 재계산: 남은 VERIFIED 구매를 구매 시각 순으로 재생, 관리자 부여는 유지.
- 등급 응답 `passOptions`: `[{productId, durationDays, expiresAtIfPurchased}]`. 앱은 상품 ID를 여기서 받는다(하드코딩 없음).
- 앱 결제 시트: 3개월(기본)·1개월, 할인 배지 `25% 할인 · 월 3,300원`, 만료일 미리보기, "자동 결제 없음". 문구 "회차 패스" > "이용권".

## 근본 원인 (확정)
만료일 계산이 시험 일정에 묶여 있었다.

## 재발 방지
- 관리자 부여 위에 이어 붙인 구매가 환불되면 재생에 관리자 부여분이 없어 그 기간이 사라진다 → 관리자가 다시 부여.
- `purchasableUntil`은 출시 앱(1.36·1.37)이 필수로 파싱해 지우지 않는다(deprecated, 3개월권 값). 최소 버전을 올린 뒤 정리.

## 교훈
상품·기간은 서버 한 곳(`PassProduct`)에서만 정하고 앱은 `passOptions` 응답에서 받는다(앱 하드코딩 없음). (볼트 정리: 상품 ID·일수만 바뀌면 앱 수정 없이 반영될 것으로 보이나 원본에 명시되지 않음)
