---
type: decision
id: DEC-0074
created: 2026-04-13
reviewed: null
topics: [design-system, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0131-markdown-rendering-ai-text]]", "[[ISS-0131-markdown-rendering-ai-text-report]]"]
---

# DEC-0074: AI 텍스트·해설·지문은 공용 `MarkdownText`로 렌더링하고 `useAiText`는 쓰지 않는다

## 문제 정의 (Context)
해설·AI 리포트가 plain text였고, 기존 단어 fade-in 훅 `useAiText`는 `innerHTML` 직접 조작이라 `ReactMarkdown`과 동시에 쓸 수 없었다(GitHub #237).

## 결정 (Decision)
`client/src/components/MarkdownText.tsx` 공용 컴포넌트로 Markdown 렌더링을 통일한다. 단어별 fade-in은 `animated` prop으로 켜고, React Context(`WordIndexContext`) + CSS custom property(`--i`)로 DOM 직접 조작 없이 구현한다. `useAiText`는 이 컴포넌트로 완전히 대체한다(이슈 본문 "useAiText 훅 삭제 (MarkdownText로 완전 대체)").

## 검토한 대안 (Alternatives)
논의 기록 없음. (기존 `useAiText` 방식은 `ReactMarkdown`과의 충돌 때문에 대체됐다.)

## 결과 (Consequences)
**긍정**
- 4곳(`PracticeResult`, `PracticeFeedbackBar`, `StatsAnalysisCard`, `QuestionDetail`)에서 서식·애니메이션을 같은 방식으로 처리.

**부정**
- `style={{ "--i": idx }}` 인라인 style을 `MarkdownText`에 한해 예외로 허용해야 한다.
- 헤딩·표 등은 `MD_COMPONENTS`에 요소를 추가해야 지원된다.

## 영향 범위 (Scope)
`client/src/components/MarkdownText.tsx`, `client/src/styles/components.css`(`.md-word`), AI 텍스트·해설·지문을 표시하는 화면.

## 출처 (References)
- GitHub #237 이슈 본문, 리포트 댓글 2개(2026-04-13)
