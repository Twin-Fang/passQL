---
type: issue
id: ISS-0338
created: 2026-10-20
topics: [practice]
symptoms: ["마크다운 표", "파이프 원문 노출", "| --- |", stem_text.dart, MarkdownText.tsx, GFM, remark-gfm, "지문 표"]
root_cause: "앱 stem_text.dart는 코드 펜스만 처리하고 표 문법 미지원, 웹 MarkdownText.tsx는 react-markdown에 GFM 표 확장이 없었다"
status: resolved
resolution: "[[ISS-0338-stem-markdown-table-raw-pipes-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/550"
---

# ISS-0338: 문제 지문의 마크다운 표가 원문 그대로 노출

GitHub #550 (원본: 이슈 본문과 댓글).

## 증상
문제 지문 안의 마크다운 표가 렌더링되지 않고 `| ENAME | SAL |`, `| --- | --- |` 원문 그대로 보인다. GitHub #504로 늘어난 실행 결과 맞히기 문제에서 지문에 표를 넣는 경우가 많다.

## 재현 조건
앱 홈 > 오늘의 세트(2026-10-20) > 8번 문제(FETCH ... WITH TIES) 지문. iOS 18.3 시뮬레이터, main 0e2fda60. 웹은 같은 증상으로 추정(실측 전).

## 조사 기록
- 2026-10-20: 앱 `app/lib/presentation/widgets/question/stem_text.dart`는 코드 펜스만 처리, 웹 `client/src/components/MarkdownText.tsx`는 표 확장(GFM) 없음.

## 근본 원인
앱·웹 지문 렌더러가 마크다운 표 문법을 지원하지 않았다.
