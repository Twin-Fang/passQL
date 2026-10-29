---
type: completion-report
id: ISS-0210
created: 2026-10-07
topics: [progress-stats, ai]
status: resolved
resolves: "[[ISS-0210-stats-ai-analysis-backticks]]"
related: ["[[ISS-0207-ai-explain-sheet-markdown-symbols]]"]
source: "https://github.com/Twin-Fang/passQL/issues/365"
---

# ISS-0210 완료 리포트: `AiAnalysisCard`가 `MarkdownLiteText`로 코멘트 표시

GitHub #365 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`AiAnalysisCard`가 `MarkdownLiteText`로 코멘트를 표시 → 백틱 숨김, 토픽명은 고정폭 강조.

## 근본 원인 (확정)
AI 분석 카드의 마크다운 미처리.

## 재발 방지
`stats_widgets_test.dart`(백틱 숨김 케이스) 통과, `flutter analyze` 이슈 없음.

## 교훈
(원본에 없음, 볼트 정리) AI 텍스트를 표시하는 새 화면이 생기면 `MarkdownLiteText`를 쓰는지 확인한다 — 같은 계열 버그가 세 번(#361·#362·#365) 나왔다.
