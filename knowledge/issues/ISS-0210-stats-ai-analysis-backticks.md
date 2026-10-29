---
type: issue
id: ISS-0210
created: 2026-10-07
topics: [progress-stats, ai]
symptoms: [AI 영역 분석 백틱 노출, AiAnalysisCard, "`데이터 모델링`", 마크다운 노출]
root_cause: "`AiAnalysisCard`가 AI 코멘트의 마크다운을 렌더링하지 않았다 — #361·#362와 같은 계열"
status: resolved
resolution: "[[ISS-0210-stats-ai-analysis-backticks-report]]"
related: ["[[ISS-0207-ai-explain-sheet-markdown-symbols]]"]
source: "https://github.com/Twin-Fang/passQL/issues/365"
---

# ISS-0210: 통계 AI 영역 분석에 마크다운 백틱이 그대로 노출됨

GitHub #365 (원본: 이슈 본문과 댓글).

## 증상
통계 화면 "AI 영역 분석" 카드에 `` `데이터 모델링`, `SELECT 기본`, … `` 처럼 백틱이 글자로 보인다.

## 재현 조건
QA GitHub #357 영역 7(iPhone 16 Pro, 실계정): 통계 탭 → "AI 영역 분석" 카드.

## 조사 기록
- 2026-10-07: GitHub #361(문제 지문)·#362(AI 해설)와 같은 계열로 판단, 기존 `MarkdownLiteText` 재사용 계획.

## 근본 원인
AI 분석 카드의 마크다운 미처리.
