---
type: issue
id: ISS-0110
created: 2026-04-12
topics: [practice]
symptoms: [RESULT_MATCH, choiceSetPolicy, "테이블 클릭 불가", "텍스트 미반전", ResultMatchTable, ChoiceCard, data-table--inverted]
root_cause: "원본에 적혀 있지 않다"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/195"
---

# ISS-0110: RESULT_MATCH 선택지 테이블 클릭 불가 · 선택 시 텍스트 미반전

GitHub #195 (원본: 이슈 본문과 이미지 댓글 하나. 텍스트 완료 기록 없음).

## 증상
`choiceSetPolicy === "RESULT_MATCH"` 선택지에서:
- 버그 1: 테이블 영역을 클릭해도 선택되지 않음. 카드 바깥 테두리만 클릭 가능.
- 버그 2: 선택(파란 배경) 후에도 테이블 헤더·셀 텍스트가 어두운 색 그대로라 가독성 없음.

## 재현 조건
1. RESULT_MATCH 문제 풀이 화면(`/practice/:sessionId` 또는 `/recommendation/:questionUuid`) 2. 테이블 셀 클릭 → 선택 안 됨 3. 테두리로 선택 → 텍스트 미반전.

## 조사 기록
- 2026-04-12: 이슈 등록. 관련 파일 `ChoiceCard.tsx`, `ResultMatchTable.tsx`, `components.css`. 기대: 카드 전체 클릭 가능, 선택 시 `data-table--inverted` 적용.
- 같은 날 이미지 댓글 하나. 수정 내용은 원본에 적혀 있지 않다(completed로 닫힘).

## 근본 원인
원본에 적혀 있지 않다.
