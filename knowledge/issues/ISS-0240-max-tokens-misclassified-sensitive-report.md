---
type: completion-report
id: ISS-0240
created: 2026-10-07
topics: [admin, security]
status: resolved
resolves: "[[ISS-0240-max-tokens-misclassified-sensitive]]"
related: ["[[DEC-0107-sensitive-key-suffix-match]]"]
source: "https://github.com/Twin-Fang/passQL/issues/408"
---

# ISS-0240 완료 리포트: 키 조각이 민감 단어로 끝날 때만 민감 판정

GitHub #408 완료 댓글 기준 (v0.0.248, PR #413). `## 개요` 형식 리포트는 없음.

## 해결 방법
키를 `. _ -`로 나눈 조각이 민감 단어로 끝날 때만 판정 (`api_key`·`apikey`·`refresh_token`은 계속 가림).

## 근본 원인 (확정)
`isSensitiveKey`가 `token` 포함 여부로 판정해 `max_tokens`까지 잠갔다.

## 재발 방지
운영 실측: `ai.default_max_tokens` `*024`·읽기전용 → `1024`·편집 가능. `ai.gemini_api_key`는 마스킹·읽기전용 유지.

## 교훈
(원본에 없음, 볼트 정리) 이름 기반 민감 판정은 부분 문자열이면 일반 설정까지 걸린다. 새 설정 키를 만들 때 이름에 민감 단어 조각이 끝에 오지 않는지 본다.
