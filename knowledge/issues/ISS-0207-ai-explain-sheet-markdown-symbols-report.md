---
type: completion-report
id: ISS-0207
created: 2026-10-07
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0207-ai-explain-sheet-markdown-symbols]]"
related: ["[[ISS-0210-stats-ai-analysis-backticks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/362"
---

# ISS-0207 완료 리포트: `MarkdownLiteText` 신설로 해설의 굵게·코드·목록 렌더링

GitHub #362 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`MarkdownLiteText` 신설: 굵게(`**`)·인라인 코드(`` ` ``)·목록(`*`, `-` → •) 렌더링(패키지 추가 없음). `ai_explain_sheet.dart`가 이 위젯으로 해설을 표시.

## 근본 원인 (확정)
해설 시트의 마크다운 미처리.

## 재발 방지
위젯 테스트 추가, 전체 7건 통과, 분석 새 경고 없음. 이후 GitHub #365에서 같은 위젯을 통계 AI 분석에 재사용.

## 교훈
(원본에 없음, 볼트 정리) LLM 응답을 표시하는 화면은 마크다운이 섞여 온다고 보고 `MarkdownLiteText`를 쓴다.
