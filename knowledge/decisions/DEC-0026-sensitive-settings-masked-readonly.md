---
type: decision
id: DEC-0026
created: 2026-04-08
reviewed: null
topics: [security, admin]
status: superseded
supersedes: null
superseded_by: DEC-0107
related: ["[[ISS-0024-admin-pages-ai-redis-settings]]", "[[ISS-0024-admin-pages-ai-redis-settings-report]]", "[[DEC-0032-gemini-key-runtime-from-settings]]", "[[DEC-0107-sensitive-key-suffix-match]]"]
---

# DEC-0026: `key`·`secret`·`password`·`token`이 들어간 설정 키는 어드민 UI에서 마스킹하고 PUT은 403

## 문제 정의 (Context)
어드민 설정 화면에서 `app_setting` 전체를 조회·수정하게 되면서 API key 같은 민감 정보 노출이 문제가 됐다 (GitHub #30).

## 결정 (Decision)
설정 키에 `key`, `secret`, `password`, `token` 문자열이 포함되면 어드민 UI에서 마스킹 표시하고, PUT API는 403을 반환한다. API Key 등 민감 정보는 UI로 수정할 수 없다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 민감 정보가 어드민 화면에 평문 노출되지 않는다.

**부정**
- 민감 설정은 UI로 바꿀 수 없다.
- (원본 기록) GitHub #47 이슈 본문은 `ai.gemini_api_key`를 `app_setting`에 추가해 "관리자 페이지에서 키를 관리할 수 있도록" 한다고 적었다. 이 키 이름은 위 규칙의 `key` 문자열을 포함한다. 두 원본 사이의 조정 방식은 원본에 적혀 있지 않다.

## 영향 범위 (Scope)
`AppSettingService.isSensitiveKey()`·`maskValue()`, `AdminSettingController`, `settings.html`. AI 서버 Redis 설정 로그도 같은 단어로 마스킹(GitHub #47).

## 출처 (References)
- GitHub #30 `## 개요` 리포트 댓글 「민감 키 보호」 (2026-04-08)
- GitHub #47 이슈 본문
