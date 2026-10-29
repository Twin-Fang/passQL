---
type: issue
id: ISS-0207
created: 2026-10-07
topics: [ai, practice]
symptoms: [AI 해설 마크다운 노출, "**굵게**", "* 목록", 백틱 노출, ai_explain_sheet.dart, MarkdownLiteText]
root_cause: "AI 해설 시트가 마크다운 표기를 렌더링하지 않고 글자 그대로 표시했다"
status: resolved
resolution: "[[ISS-0207-ai-explain-sheet-markdown-symbols-report]]"
related: ["[[ISS-0210-stats-ai-analysis-backticks]]", "[[ISS-0199-ai-explain-always-unavailable]]"]
source: "https://github.com/Twin-Fang/passQL/issues/362"
---

# ISS-0207: AI 해설 시트에 마크다운 기호(**, `, *)가 그대로 노출됨

GitHub #362 (원본: 이슈 본문과 댓글).

## 증상
오답 후 "AI에게 자세히 물어보기"로 여는 해설 시트에 `**C번**`, `` `PIVOT` ``, `* **C번(...)**:` 등 기호가 그대로 보인다. 해설 내용과 동작은 정상.

## 재현 조건
QA GitHub #357 영역 3(iPhone 16 Pro, 실계정): 오늘의 세트 2번 문제에서 오답(C) 제출 → "AI에게 자세히 물어보기".

## 조사 기록
- 2026-10-07: 작업 범위를 "패키지 추가 없이 공용 위젯 확장"으로 정함. 이유는 원본에 적혀 있지 않다.

## 근본 원인
해설 텍스트 렌더링에 마크다운 처리가 없었다.
