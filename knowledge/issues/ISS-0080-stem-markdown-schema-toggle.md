---
type: issue
id: ISS-0080
created: 2026-04-12
topics: [practice, question-bank]
symptoms: ["지문 백틱 노출", "마크다운 미렌더링", "```sql", react-markdown, SchemaViewer, "스키마 접기/펼치기"]
root_cause: "기능 개선 — stem을 마크다운으로 렌더링하지 않아 SQL 코드 블록이 백틱 그대로 노출되고, 스키마가 항상 펼쳐져 화면이 길었다"
status: resolved
resolution: "[[ISS-0080-stem-markdown-schema-toggle-report]]"
related: ["[[DEC-0056-stem-sql-code-block-rule]]", "[[ISS-0082-executable-result-compare-ui]]"]
source: "https://github.com/Twin-Fang/passQL/issues/140"
---

# ISS-0080: 문제 지문 마크다운 렌더링 및 스키마 접기/펼치기

GitHub #140 (원본: 이슈 본문과 댓글).

## 증상
문제 지문(stem)의 ` ```sql ``` ` 코드 블록이 백틱 문자 그대로 노출된다. `SchemaViewer`가 항상 펼쳐져 화면이 길고 토글이 없다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 본문 — `react-markdown`으로 stem 렌더링, SQL 코드 블록 회색 배경, 접힌 상태는 마크다운 문법 제거한 한 줄 미리보기, SchemaViewer 토글(기본 접힘).
- 2026-04-12: "Stable 적용 완료" 댓글. 이어지는 UI 작업은 GitHub #144에서 처리.
- 2026-04-12: 같은 이슈에서 관리자 문제 등록 가이드에 stem 마크다운 규칙을 추가하기로 함(결정 참고).

## 근본 원인
해당 없음 (기능 개선).
