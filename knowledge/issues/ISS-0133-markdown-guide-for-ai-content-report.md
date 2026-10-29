---
type: completion-report
id: ISS-0133
created: 2026-04-13
topics: [question-bank, ai]
status: resolved
resolves: "[[ISS-0133-markdown-guide-for-ai-content]]"
related: ["[[DEC-0076-markdown-rules-for-generated-content]]"]
source: "https://github.com/Twin-Fang/passQL/issues/243"
---

# ISS-0133 완료 리포트: 가이드에 마크다운 활용 규칙 추가, 3개 화면 `MarkdownText`로 통일

GitHub #243 `## 개요` 리포트 댓글과 "적용완료" 댓글(2026-04-13) 기준.

## 해결 방법
- `question-single-guide.md`, `question-bulk-guide.md`(`server/PQL-Web/src/main/resources/static/docs/`): "마크다운 활용 규칙" 섹션(문법 표, 필드별 활용법, 체크리스트), AI 변환 프롬프트에 마크다운 지시.
- `client/src/components/AiExplanationSheet.tsx`: 70줄 커스텀 `renderMarkdown()` 파서 + `useMemo` 삭제 → `MarkdownText` (128줄 → 57줄).
- `client/src/components/ChoiceCard.tsx`: CONCEPT_ONLY 선택지를 `MarkdownText`로.
- `client/src/pages/AnswerFeedback.tsx`: rationale을 `MarkdownText`로.
- `client/src/styles/components.css`: `.choice-text-inverted, .choice-text-inverted *`로 확장해 내부 요소까지 흰색 반전.

## 근본 원인 (확정)
가이드·프롬프트에 마크다운 지시가 없었고 일부 화면이 plain text 렌더링이었다.

## 재발 방지
리포트 주의사항: DB `prompt_template`에도 지시를 넣으면 rationale 품질이 더 나아질 수 있으나 Flyway 마이그레이션으로 별도 처리 필요. 반영 여부는 원본에 적혀 있지 않다.

## 교훈
논의 기록 없음.
