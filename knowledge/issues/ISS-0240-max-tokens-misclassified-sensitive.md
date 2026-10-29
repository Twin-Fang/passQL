---
type: issue
id: ISS-0240
created: 2026-10-07
topics: [admin, security]
symptoms: [ai.default_max_tokens, isSensitiveKey, "*024", "읽기전용", "민감 키 오인", "403", AppSettingService]
root_cause: "`AppSettingService.isSensitiveKey`가 키 문자열에 `token`이 포함되면 민감으로 봐서 `max_tokens`도 걸렸다"
status: resolved
resolution: "[[ISS-0240-max-tokens-misclassified-sensitive-report]]"
related: ["[[DEC-0107-sensitive-key-suffix-match]]"]
source: "https://github.com/Twin-Fang/passQL/issues/408"
---

# ISS-0240: 앱 설정 `ai.default_max_tokens`가 민감 키로 오인돼 값이 가려지고 수정 불가

GitHub #408 (원본: 이슈 본문과 완료 댓글).

## 증상
관리자 > 앱 설정에서 `ai.default_max_tokens`(AI 기본 최대 토큰, 정수)가 민감 키로 분류된다. 값이 `*024`로 가려지고 액션이 "읽기전용"이라 바꿀 수 없다. API로 보내도 403.

## 재현 조건
운영 관리자(v0.0.247, 2026-10-08). 관리자 로그인 → 앱 설정 → `ai.default_max_tokens` 행: 🔒 배지, 값 `*024`, "읽기전용".

## 조사 기록
- 2026-10-07: 원인 — `isSensitiveKey`가 `token` 포함 여부로 판정.

## 근본 원인
민감 키 판정이 부분 문자열 포함 검사였다.
