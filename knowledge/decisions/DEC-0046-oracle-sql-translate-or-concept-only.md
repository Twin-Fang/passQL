---
type: decision
id: DEC-0046
created: 2026-04-11
reviewed: null
topics: [question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0056-oracle-dialect-bulk-import-sandbox-fail]]", "[[ISS-0056-oracle-dialect-bulk-import-sandbox-fail-report]]"]
---

# DEC-0046: Oracle SQL은 안전한 1:1 치환(`NVL`, `SYSDATE`)만 자동 변환하고, 남는 Oracle 전용 문법은 `CONCEPT_ONLY`로 전환한다

## 문제 정의 (Context)
SQLD 기출은 Oracle 기준인데 Sandbox는 MariaDB라 Oracle 문법 문제가 모두 FAIL로 처리됐다 (GitHub #100).

## 결정 (Decision)
- 1단계 `translateOracleToMariaDb()`: `NVL(a, b)` → `IFNULL(a, b)`, `SYSDATE` → `NOW()`만 정규식으로 치환한다.
- 2단계 `detectOracleOnlySyntax()`: 치환 후에도 남은 Oracle 전용 문법(`CONNECT BY`, `ROWNUM`, `NVL2`, `DECODE`, `TO_DATE`, `TO_CHAR`, `PIVOT`, `MERGE INTO`, `.NEXTVAL`, `ADD_MONTHS`, 이후 `FULL OUTER JOIN` 등)이 있으면 `CONCEPT_ONLY`로 전환하고 Sandbox를 건너뛴다.
- 벌크 임포트(validate·import)와 단건 등록에 같은 로직을 쓰고, 치환된 SQL을 DB에 저장한다.

## 검토한 대안 (Alternatives)
- `TO_DATE` → `STR_TO_DATE`, `SUBSTR` → `SUBSTRING`, `INSTR` → `LOCATE` 등 더 넓은 치환(이슈 본문 예상 동작): 리포트는 `NVL2`, `DECODE`, `TO_DATE`, `TO_CHAR`가 인자 개수·순서·포맷 코드 체계가 달라 단순 문자열 치환 시 오작동 위험이 있어 치환에서 빼고 감지 대상으로 두었다고 적었다. `SUBSTR`·`INSTR`을 뺀 이유는 원본에 적혀 있지 않다.
- `REGEXP_REPLACE`: MariaDB 10.0.5+ 지원이라 감지 목록에서 제외.

## 결과 (Consequences)
**긍정**
- 검증에 쓴 SQL과 저장되는 SQL이 일치한다. 이슈 본문은 가이드에 "Oracle 기준으로 작성해도 된다"는 안내를 넣자고 했다.

**부정**
- 실행 가능한 일부 문법(`GROUPING SETS`, 단순 `FROM DUAL`, `START WITH`)도 감지돼 `CONCEPT_ONLY`가 될 수 있다(리포트 주의사항).

## 영향 범위 (Scope)
`QuestionImportExportService`(`translateOracleToMariaDb`, `detectOracleOnlySyntax`, `validateSingleItem`, `importBatch`), `AdminQuestionController.register()`.

## 출처 (References)
- GitHub #100 이슈 본문 「예상 동작」·「해결 방안」, 첫 리포트 댓글 「치환 범위 설계 원칙」(2026-04-11), 두 번째 리포트 댓글 주의사항
