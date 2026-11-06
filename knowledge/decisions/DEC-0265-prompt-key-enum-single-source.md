---
type: decision
id: DEC-0265
created: 2026-11-07
reviewed: null
topics: [ai, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0464-admin-prompt-key-single-source]]", "[[ISS-0464-admin-prompt-key-single-source-report]]"]
---

# DEC-0265: 프롬프트 키는 `PromptKey` enum 한 곳을 원본으로 두고, 관리자 수정에서는 키를 바꿀 수 없다

## 문제 정의 (Context)
관리자 수정 폼 키 목록이 3개로 하드코딩돼 저장 시 키가 `explain_error` 로 바뀔 수 있었고, 키 문자열이 서비스 6곳에 흩어져 있었다 (GitHub #875, [[ISS-0464-admin-prompt-key-single-source]]).

## 결정 (Decision)
- `PromptKey` enum 이 코드가 읽는 프롬프트 키의 단일 원본. 서비스는 이 enum 을 쓰고 `getActivePrompt` 인자도 `PromptKey` 타입이라 문자열 키는 컴파일 단계에서 막힌다.
- 관리자 수정 폼은 키 읽기 전용, 서버 `PromptService.update` 는 요청의 키를 무시하고 기존 키를 유지(경고 로그).
- 등록 폼 키 목록은 `PromptKey` 에서 만들고, DB 에만 있는 옛 키는 "코드에서 읽지 않는 키"로 구분해 보여 준다.
- 규칙 테스트 `server-prompt-key-single-source` 로 흩어진 키 문자열을 막는다.
- 새 프롬프트 키를 추가할 때는 `PromptKey` 에 먼저 넣는다.

## 검토한 대안 (Alternatives)
- 화면 목록에 빠진 키만 추가: 이슈가 지적한 "새 키를 추가하면 화면 목록과 쉽게 어긋난다" 문제가 남는다 (그 밖의 논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 화면 실수가 다시 생겨도 서버가 키 변경을 막는다. 새 키가 화면 목록에 자동으로 나온다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 `PromptKey`, `PromptService`, 프롬프트를 읽는 서비스들, 관리자 `templates/admin/prompts.html`, 규칙 테스트 `server-prompt-key-single-source`.

## 출처 (References)
- GitHub #875 이슈 본문·리포트 댓글 (2026-11-07)
