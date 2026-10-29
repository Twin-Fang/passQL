---
type: decision
id: DEC-0002
created: 2026-10-22
reviewed: null
topics: [billing]
status: superseded
supersedes: DEC-0001
superseded_by: DEC-0003
related: ["[[ISS-0003-free-pro-plan-android-exam-pass]]"]
---

# DEC-0002: 결제 상품은 다음 SQLD 시험일까지 쓰는 일회성 "회차 패스"

## 문제 정의 (Context)
passQL은 SQLD 수험서를 대체하는 앱인데 수익 구조가 없었다. 무료로도 계속 쓸 수 있지만 쓸수록 프로가 아쉬워지는 구조가 필요했다 (GitHub #576).

## 결정 (Decision)
상품은 회차 패스(`pro_exam_pass`, 소모형): 다음 SQLD 시험일까지. 만료일 = 다음 시험일 23:59:59, 시험이 14일 안이면 그다음 회차, 예정 시험이 없으면 90일, 재구매는 다음 회차로 연장. 가격은 책보다 싸게, 출시 직전 스토어에서 결정. 체험 기간 없음. Android 먼저.

## 검토한 대안 (Alternatives)
논의 기록 없음. (당시 열려 있던 #501의 월간·연간 구독 계획 [[DEC-0001-pro-monthly-yearly-subscription]]과의 비교도 원본에 없다.)

## 결과 (Consequences)
**긍정**
- 논의 기록 없음

**부정**
- (이후 #591 이슈 본문) 만료일 계산이 시험일 기준이라 기간제·연장(이어 붙이기)을 표현하지 못한다.

## 영향 범위 (Scope)
`ExamPassExpiryCalculator`, Play 상품 `pro_exam_pass`, 구매 시트 문구. 이후 [[DEC-0003-one-and-three-month-pass]]로 대체되며 계산기는 삭제됐고, Play에 이 상품은 실제로 만들어지지 않았다(#591 리포트).

## 출처 (References)
- GitHub #576 이슈 본문·리포트
- [[ISS-0003-free-pro-plan-android-exam-pass]]
