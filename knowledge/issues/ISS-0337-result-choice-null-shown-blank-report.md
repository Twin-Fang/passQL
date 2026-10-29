---
type: completion-report
id: ISS-0337
created: 2026-10-21
topics: [practice]
status: resolved
resolves: "[[ISS-0337-result-choice-null-shown-blank]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/549"
---

# ISS-0337 완료 리포트: 앱·웹 표 컴포넌트가 NULL을 흐린 `NULL`로 그림

GitHub #549 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 b35a476c, v1.27.0.

## 해결 방법
- 앱: `result_rows_table.dart`에 NULL 표기 단일 원본 `sqlNullCellLabel` 추가(null이면 흐린 색 tertiaryLabel `NULL`, 모자란 칸은 빈칸). `schema_table_preview.dart`는 이 상수 참조, `execute_result_card.dart`의 `cellValue ?? 'NULL'` 직접 치환 제거.
- 웹: `client/src/lib/sqlCellPresentation.ts`에 `SQL_NULL_CELL_LABEL`, `isSqlNullCell`, `toSqlCellText`(스키마 표·실행 결과·결과형 보기 공통). `ResultMatchTable.tsx`의 `row[col] ?? ""`를 공통 함수 + `result-table-null` 클래스로. `ResultTable.tsx`, `SchemaViewer.tsx`도 공통 함수 사용.

## 근본 원인 (확정)
NULL 리터럴이 앱 3곳·웹 3곳에 흩어져 있었고 결과형 보기 표만 null을 빈 문자열로 처리했다.

## 재발 방지
- 테스트: 앱 `choice_item_card_test`(NULL > `NULL`, 빈 문자열 > 빈칸), 웹 `MarkdownText.test.tsx` ResultMatchTable NULL 테스트.
- 주의: 결과 JSON에서 키가 빠진 칸도 null로 읽혀 `NULL`로 보인다(보기 데이터는 키를 빠뜨리지 않는 전제). 웹 화면 실측은 로그인 제약으로 못 했다.

## 교훈
(원본에 없음, 볼트 정리) 같은 값의 표시 규칙이 여러 표 컴포넌트에 흩어져 있으면 공통 상수·함수 한 곳으로 모은다.
