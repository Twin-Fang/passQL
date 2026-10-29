---
type: issue
id: ISS-0131
created: 2026-04-13
topics: [design-system, ai]
symptoms: ["마크다운 깨짐", "plain text 렌더링", useAiText, innerHTML, ReactMarkdown, rationale, "AI 리포트", "인라인 코드 애니메이션 순서"]
root_cause: "해설·AI 리포트가 plain text로 렌더링되고, 단어 fade-in 훅 `useAiText`가 `innerHTML` 직접 조작이라 `ReactMarkdown`과 함께 쓸 수 없음"
status: resolved
resolution: "[[ISS-0131-markdown-rendering-ai-text-report]]"
related: ["[[DEC-0074-shared-markdowntext-component]]"]
source: "https://github.com/Twin-Fang/passQL/issues/237"
---

# ISS-0131: AI 피드백·해설·지문의 Markdown 서식이 깨져 보임

GitHub #237 (원본: 이슈 본문과 댓글 2개).

## 증상
- `PracticeFeedbackBar` 해설(rationale), `PracticeResult` AI 리포트가 plain text라 `**굵게**`·코드 서식이 그대로 노출.
- `QuestionDetail.tsx` 지문(stem)은 인라인 `ReactMarkdown`이라 재사용 불가.
- AI 리포트의 단어별 fade-in(`useAiText`)이 `innerHTML` 직접 조작 방식이라 `ReactMarkdown`과 충돌.

## 재현 조건
AI 응답이나 해설에 Markdown 문법이 들어 있을 때.

## 조사 기록
- 2026-04-13: 공용 `MarkdownText` 도입(리포트 댓글).
- 2026-04-13: 후속 버그 — 인라인 코드가 있으면 코드 배경(`bg-surface-code`)만 먼저 뜨고 코드가 늦게 등장, 빈 `md-word` span 생성.

## 근본 원인
`useAiText`가 React 관리 밖에서 DOM을 조작(`container.innerHTML = ""`)했다. 후속 버그는 `animateTextNodes`가 string 노드만 인덱스를 소비하고 `MdInlineCode`는 렌더 시점에 늦게 소비한 것, 그리고 `text.split(/(\s+)/)`가 만든 빈 문자열 토큰.
