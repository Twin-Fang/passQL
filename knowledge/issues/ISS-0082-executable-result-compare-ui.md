---
type: issue
id: ISS-0082
created: 2026-04-12
topics: [practice]
symptoms: ["SQL 실행 비교 화면 길어짐", "실행 결과 테이블 가독성", AnswerFeedback, ResultTable, EXECUTABLE, "선택지 4개 결과 나열"]
root_cause: "디자인 개선 요청 — 제출 후 선택지별 SQL 실행 결과가 모두 자동 노출되고 결과 테이블 스타일이 스키마 보기와 달랐다"
status: resolved
resolution: "[[ISS-0082-executable-result-compare-ui-report]]"
related: ["[[DEC-0058-on-demand-choice-execution-after-submit]]", "[[ISS-0080-stem-markdown-schema-toggle]]", "[[ISS-0089-apply-144-pattern-daily-recommend]]"]
source: "https://github.com/Twin-Fang/passQL/issues/144"
---

# ISS-0082: EXECUTABLE 문제 제출 후 SQL 실행 비교 화면 UI/UX 개선

GitHub #144 (원본: 이슈 본문과 작업 댓글).

## 증상
`executionMode: "EXECUTABLE"` 문제 제출 후 각 선택지의 SQL 실행 결과가 하단에 모두 나열돼 화면이 지나치게 길다(선택지 4개면 결과 4개). 결과 테이블이 단순 텍스트 나열이라 가독성이 낮다.

## 재현 조건
해당 없음 (디자인 개선 요청).

## 조사 기록
- 2026-04-12: 이슈 본문 기대 결과 — 실행 비교는 접기/펼치기 또는 탭 전환으로 원할 때 확인, 결과 테이블은 스키마 보기와 같은 스타일, 정답/오답 결과 시각 구분.

## 근본 원인
해당 없음 (디자인 개선).
