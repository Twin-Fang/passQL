---
type: issue
id: ISS-0219
created: 2026-10-07
topics: [community]
symptoms: ["건의사항 500자", "550/500", "입력 제한 없음", FeedbackValidator]
root_cause: "건의사항 입력창에 길이 제한 포매터가 적용되지 않았다"
status: resolved
resolution: "[[ISS-0219-feedback-input-500-char-limit-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/374"
---

# ISS-0219: 건의사항 입력창이 500자를 넘어도 계속 입력됨 (앱)

GitHub #374 (원본: 이슈 본문과 완료 댓글). GitHub #370 후보 5.

## 증상
500자 제한을 넘겨도 계속 입력된다(카운터만 빨간색 550/500, 전송 버튼은 비활성). 동작은 안전하지만 입력 자체를 막는 편이 자연스럽다고 적었다.

## 재현 조건
건의사항 입력창에 500자 넘게 입력.

## 조사 기록
- 2026-10-07: 작업 범위 — 입력창에 500자 제한 적용(카운터 유지).

## 근본 원인
입력창에 길이 제한이 걸려 있지 않았다 (완료 댓글의 수정 내용에서 읽힘).
