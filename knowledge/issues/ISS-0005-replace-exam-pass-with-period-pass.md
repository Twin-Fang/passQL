---
type: issue
id: ISS-0005
created: 2026-10-23
topics: [billing]
symptoms: [pro_exam_pass, pro_pass_1m, pro_pass_3m, "만료일 계산", "시험일 기준", "연장 이어 붙이기", ExamPassExpiryCalculator, PassExpiryCalculator]
root_cause: "결제 상품이 다음 SQLD 시험일까지인 회차 패스 하나였고 만료일 계산이 시험일 기준이라 기간제·연장을 표현하지 못했다"
status: resolved
resolution: "[[ISS-0005-replace-exam-pass-with-period-pass-report]]"
related: ["[[DEC-0003-one-and-three-month-pass]]"]
source: "https://github.com/Twin-Fang/passQL/issues/591"
---

# ISS-0005: 회차 패스를 1개월, 3개월 이용권으로 교체 (서버, Android)

GitHub #591 (원본: 이슈 본문과 `## 개요` 리포트 댓글).

## 증상
#576의 결제 상품은 회차 패스(`pro_exam_pass`, 다음 SQLD 시험일까지) 하나. 2026-10-23 결정(#578 댓글)으로 1개월권 ₩4,400, 3개월권 ₩9,900 기간제 이용권으로 바꾸기로 했는데, 서버 만료일 계산이 시험일 기준이라 기간제·연장을 표현하지 못한다.

## 재현 조건
해당 없음 (상품 구조 변경).

## 조사 기록
- 2026-10-23: 결정 반영 범위를 서버·Android·Play Console로 정함. 결제 스위치는 이 이슈에서 켜지 않는다.

## 근본 원인
상품과 만료일 계산이 "시험 회차" 개념에 묶여 있었다.
