---
type: completion-report
id: ISS-0056
created: 2026-04-11
topics: [question-bank, admin]
status: resolved
resolves: "[[ISS-0056-oracle-dialect-bulk-import-sandbox-fail]]"
related: ["[[DEC-0046-oracle-sql-translate-or-concept-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/100"
---

# ISS-0056 완료 리포트: Oracle 문법 치환·`CONCEPT_ONLY` 전환과 Sandbox URL 파싱 수정

GitHub #100 리포트 댓글 두 개(2026-04-11)와 "정상 작동 확인" 댓글 기준.

## 해결 방법
- `QuestionImportExportService`: `translateOracleToMariaDb(String sql)`(정규식, 대소문자 무관, `\b` word boundary로 `NVL(` → `IFNULL(`, `SYSDATE` → `NOW()`), `detectOracleOnlySyntax(...)`(치환 불가 키워드 23종 감지). `validateSingleItem()`은 치환 → 감지 순서, 치환된 SQL로 Sandbox 실행. `importBatch()`도 치환된 SQL을 저장하고 감지 시 `CONCEPT_ONLY`로 저장.
- `AdminQuestionController.register()`(단건 등록)에도 같은 치환·전환 적용.
- `SandboxPool.createDataSource()`·`buildAdminDataSource()`: `lastIndexOf("/")`를 `?` 앞 경로 부분에만 적용.
- `SandboxExecutor.applyDdl()`에 디버그 로그. `detectOracleOnlySyntax()` 목록에 `FULL OUTER JOIN` 추가.

## 근본 원인 (확정)
방언 처리 부재, 그리고 쿼리 파라미터의 `/`를 DB명 경계로 잡은 URL 파싱.

## 재발 방지
리포트 주의사항: 버그 기간에 `passql_sandbox` DB에 DEPT·EMP 등 테이블이 쌓였을 수 있어 정리를 권장. `Unknown column 'A.ID'` 오류 3건은 JSON 데이터 자체 오류. `GROUPING SETS`, `FROM DUAL`, `START WITH`는 감지 대상으로 유지(향후 정밀화 가능).

## 교훈
(원본에 없음, 볼트 정리) 샌드박스에서 `Duplicate entry ... PRIMARY`가 대량으로 나면 새 임시 DB가 아니라 공용 DB에 붙었는지(JDBC URL 조립)부터 본다.
