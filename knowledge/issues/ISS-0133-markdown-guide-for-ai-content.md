---
type: issue
id: ISS-0133
created: 2026-04-13
topics: [question-bank, ai]
symptoms: ["마크다운 미활용", stem, rationale, hint, "인라인 코드 없음", AiExplanationSheet, renderMarkdown, "plain text 해설"]
root_cause: "AI가 생성하는 stem·hint·rationale에 마크다운을 거의 쓰지 않고, 일부 화면은 여전히 plain text 렌더링"
status: resolved
resolution: "[[ISS-0133-markdown-guide-for-ai-content-report]]"
related: ["[[DEC-0076-markdown-rules-for-generated-content]]", "[[DEC-0074-shared-markdowntext-component]]"]
source: "https://github.com/Twin-Fang/passQL/issues/243"
---

# ISS-0133: AI 생성 콘텐츠가 마크다운을 쓰지 않아 가독성이 떨어짐

GitHub #243 (원본: 이슈 본문과 댓글).

## 증상
프론트는 `MarkdownText`(`react-markdown`)로 stem·rationale을 렌더링하지만, AI가 생성한 stem·rationale·hint는 마크다운을 거의 쓰지 않아 SQL 키워드·함수명이 일반 텍스트로 보인다. 예: `LAG(SAL, 1, 0)`이 인라인 코드가 아닌 일반 텍스트.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-13: 제안 — 등록 가이드에 마크다운 활용 규칙 섹션, AI 변환 프롬프트에 지시 추가, DB `prompt_template` 반영 검토.

## 근본 원인
등록 가이드·프롬프트에 마크다운 사용 지시가 없었다.
