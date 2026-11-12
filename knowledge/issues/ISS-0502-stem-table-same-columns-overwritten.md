---
type: issue
id: ISS-0502
created: 2026-11-12
topics: [practice, question-bank, design-system]
symptoms: ["지문 표 사라짐", "같은 표 두 번", "EMP 표 안 보임", "PROJ 두 번", "컬럼이 같은 다른 표", "columnSignature", "_placeSchemaTables", "제약 주석이 코드 제목", "코드 제목 보라색 글자", "stem_blocks.dart", "stemSchemaTablePlacement.ts"]
root_cause: "스키마 표를 지문 표 자리에 끼울 때 이름 없이 컬럼 서명만 보고 첫 번째 블록을 골라, 같은 컬럼의 다른 표가 이미 대체된 자리를 다시 덮었고, 코드 첫 줄 -- 주석은 무엇이든 코드 제목으로 뗐다"
status: resolved
resolution: "[[ISS-0502-stem-table-same-columns-overwritten-report]]"
related: ["[[DEC-0292-stem-table-match-by-name-short-code-caption]]", "[[ISS-0472-stem-readability-blocks-single-table]]", "[[ISS-0504-question-structure-audit-harness]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1015"
---

# ISS-0502: 지문 표가 컬럼이 같은 다른 표로 덮이고, 제약 주석이 코드 제목으로 빠짐

GitHub #1015. 원본 사본: `_sources/issues/ISS-0502-stem-table-same-columns-overwritten.md`(로컬). #903([[ISS-0472-stem-readability-blocks-single-table]])의 "같은 컬럼 표는 한 번" 규칙에서 생긴 회귀.

## 증상
- 지문에 이름이 다른데 컬럼이 같은 표가 있으면(`[EMP] (ID, DEPT_NO)`와 스키마 `PROJ (ID, DEPT_NO)`) EMP 데이터가 사라지고 PROJ 표가 두 번 보임.
- `EMP.DEPT_NO : REFERENCES … ON DELETE SET NULL` 같은 제약 설명 주석이 코드 밖 제목(보라색 글자)으로 빠짐.

## 재현 조건
오늘의 세트 DDL/DML/TCL 문제 "다음 SQL 을 수행한 뒤 마지막 SELECT 결과(EMP 행 수, …)로 옳은 것은?". 앱·웹 공통 규칙.

## 조사 기록
- 2026-11-12: 데이터는 정상(지문·스키마 DDL·INSERT 모두 EMP 있음). 앱 `_placeSchemaTables`가 서명이 같은 첫 지문 블록을 교체 > 스키마 PROJ가 이미 EMP로 바뀐 자리를 다시 덮음. 웹은 대체 자리 재사용은 막았지만 이름을 안 봐 순서가 뒤바뀔 수 있었음.
- 2026-11-12: 4d349dc7, PR #1018, 배포 PR #1019.

## 근본 원인
표 배치가 이름을 보지 않고 컬럼 서명만 비교. 코드 제목 판정이 주석 내용을 구분하지 않음.
