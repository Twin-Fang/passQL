---
type: issue
id: ISS-0107
created: 2026-04-12
topics: [practice]
symptoms: [parseSampleData, "VALUES (1),(2),(3)", "다중 행 INSERT", "샘플 데이터 깨짐", SchemaViewer, SqlPlayground, "catch 없음", btn-run-all, ResultTable]
root_cause: "parseSampleData 정규식 `\\((.+?)\\)`이 non-greedy라 다중 행 VALUES에서 첫 행 이후를 버렸다"
status: resolved
resolution: "[[ISS-0107-execute-ui-sample-data-parsing-fix-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/191"
---

# ISS-0107: 실행 UI 통일 · 샘플 데이터 파싱 버그 · 결과 테이블 가독성

GitHub #191 (원본: 이슈 본문, 스크린샷·리포트 댓글).

## 증상
- 실행 버튼 스타일이 `ChoiceCard`, `SqlPlayground`, `AnswerFeedback`에서 제각각(`btn btn-xs btn-outline`, `btn-compact`, `btn-run-all`).
- `INSERT INTO T1 VALUES (1), (2), (3)` 형식 샘플 데이터를 파싱하지 못해 스키마 샘플 데이터가 깨져 표시.
- `SqlPlayground`에서 네트워크 오류·5xx 시 `catch`가 없어 에러가 조용히 사라짐.
- 선택된 ChoiceCard(파란 배경) 위 `ResultTable`이 흰 박스로 감싸져 튐. 미사용 `questionUuid` prop, 튀는 헤더 "SQL 실행기", textarea 인라인 `style` 5개.

## 재현 조건
다중 행 INSERT 샘플 데이터를 가진 문제 진입 → 샘플 데이터 표시 깨짐.

## 조사 기록
- 2026-04-12: 이슈 등록과 수정(리포트 댓글).

## 근본 원인
파싱: 기존 정규식 `\((.+?)\)`이 non-greedy로 `(1)` 이후를 버렸다. 에러 무음: `handleExecute`에 `catch` 블록이 없었다.
