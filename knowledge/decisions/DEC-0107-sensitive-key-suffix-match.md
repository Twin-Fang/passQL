---
type: decision
id: DEC-0107
created: 2026-10-07
reviewed: null
topics: [admin, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0240-max-tokens-misclassified-sensitive]]", "[[ISS-0240-max-tokens-misclassified-sensitive-report]]"]
---

# DEC-0107: 설정 키 민감 판정은 `. _ -`로 나눈 조각이 민감 단어로 끝날 때만

GitHub #408 (원본: 이슈 본문과 완료 댓글). 기존 민감 키 규칙은 볼트 DEC-0026(키에 `key`·`secret`·`password`·`token` 포함 시 마스킹·PUT 403).

## 문제 정의 (Context)
`AppSettingService.isSensitiveKey`가 키에 `token`이 포함되면 민감으로 판정해 `ai.default_max_tokens`가 `*024`로 가려지고 수정할 수 없었다. 이슈의 예상 동작: 비밀값(`ai.gemini_api_key` 등)만 가리고 일반 설정은 보이고 수정 가능.

## 결정 (Decision)
키를 `. _ -`로 나눈 조각이 민감 단어로 끝날 때만 민감으로 판정한다. `api_key`·`apikey`·`refresh_token`은 계속 가린다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- `ai.default_max_tokens`가 `1024`로 보이고 편집 가능, `ai.gemini_api_key`는 마스킹 유지 (운영 실측).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`AppSettingService.isSensitiveKey`, 관리자 앱 설정 화면과 설정 PUT API.

## 출처 (References)
- GitHub #408 이슈 본문, 완료 댓글(v0.0.248, PR #413)
- [[ISS-0240-max-tokens-misclassified-sensitive]]
