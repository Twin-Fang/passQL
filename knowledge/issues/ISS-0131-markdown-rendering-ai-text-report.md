---
type: completion-report
id: ISS-0131
created: 2026-04-13
topics: [design-system, ai]
status: resolved
resolves: "[[ISS-0131-markdown-rendering-ai-text]]"
related: ["[[DEC-0074-shared-markdowntext-component]]"]
source: "https://github.com/Twin-Fang/passQL/issues/237"
---

# ISS-0131 완료 리포트: 공용 `MarkdownText`로 4곳 Markdown 렌더링 통일

GitHub #237 `## 개요` 리포트 댓글 2개(2026-04-13) 기준.

## 해결 방법
- `client/src/components/MarkdownText.tsx` 신규: `animated` prop으로 단어별 fade-in, `ReactMarkdown` `components`로 `p`, `strong`, `em`, `code`, `pre`, `ul`, `ol`, `li`에 디자인 시스템 클래스(`bg-surface-code`, `font-mono`, `font-bold` 등) 주입. `animated=true`면 `WordIndexContext`로 단어 인덱스를 공유하고 텍스트를 `<span className="md-word" style={{ "--i": idx }}>`로 분해.
- `client/src/styles/components.css`: `.md-word`, `animation-delay: calc(var(--i, 0) * 55ms + 200ms)`, 기존 `ai-word-in` 키프레임 재사용.
- 사용처: `PracticeResult.tsx`(animated), `PracticeFeedbackBar.tsx`(정적), `StatsAnalysisCard.tsx`(animated), `QuestionDetail.tsx`(stem).
- `MD_COMPONENTS`를 모듈 스코프 상수로 둬 불필요한 리렌더 방지. 인라인 코드는 단어 분해 없이 통째로.
- 후속 수정: `splitToAnimatedSpans`에 `if (!token || /^\s+$/.test(token)) return token;`, `animateTextNodes`가 `el.type === MdInlineCode`를 식별해 그 자리에서 인덱스를 소비하고 `md-word` span으로 감싼다. `pre` 코드 블록은 애니메이션 없음.

## 근본 원인 (확정)
`useAiText`의 `innerHTML` 직접 조작이 `ReactMarkdown`과 공존할 수 없었다. 후속 버그는 인라인 코드 인덱스 소비 타이밍과 빈 토큰.

## 재발 방지
리포트 주의사항:
- `style={{ "--i": idx }}`는 CLAUDE.md 인라인 style 금지 규칙의 예외로 `MarkdownText`에 한해 허용.
- `useAiText.ts`는 참조가 없는 데드코드로 남음, 팀 확인 후 삭제 예정.
- AI가 Markdown을 얼마나 쓰는지 미확인. 헤딩·표는 필요 시 `MD_COMPONENTS`에 추가.
- `el.type === MdInlineCode`는 함수 참조 동일성에 의존 — 컴포넌트를 외부로 분리하면 비교도 함께 옮겨야 한다.

## 교훈
논의 기록 없음.
