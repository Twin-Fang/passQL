---
type: completion-report
id: ISS-0219
created: 2026-10-07
topics: [community]
status: resolved
resolves: "[[ISS-0219-feedback-input-500-char-limit]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/374"
---

# ISS-0219 완료 리포트: `LengthLimitingTextInputFormatter(500)` 적용

GitHub #374 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`FeedbackValidator.inputFormatters`(`LengthLimitingTextInputFormatter(500)`)를 입력창에 적용 — 500자에서 입력이 멈추고 카운터는 500/500.

## 근본 원인 (확정)
입력창에 길이 제한 포매터가 없었다.

## 재발 방지
단위 테스트(550자 입력 → 500자) 통과, 시뮬레이터 실측 확인.

## 교훈
원본에 적혀 있지 않다.
