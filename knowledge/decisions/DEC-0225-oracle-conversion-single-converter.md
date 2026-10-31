---
type: decision
id: DEC-0225
created: 2026-10-31
reviewed: null
topics: [question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0434-audit-followup-split-large-files]]", "[[ISS-0434-audit-followup-split-large-files-report]]", "[[DEC-0046-oracle-sql-translate-or-concept-only]]"]
---

# DEC-0225: Oracle 변환·Oracle 전용 문법 감지는 `OracleSqlCompatibilityConverter` 한 곳에서 하고, 컨트롤러는 서비스 호출만 한다 (호출부별 차이는 보존)

## 문제 정의 (Context)
Oracle → PostgreSQL 변환과 Oracle 전용 문법 감지가 `AdminQuestionController`, `QuestionImportItemValidator`, `QuestionImportExportService`에 3벌 있었고, 그중 1벌은 컨트롤러에 있었다 (GitHub #762).

## 결정 (Decision)
- 변환·감지를 `OracleSqlCompatibilityConverter.toPostgresCompatible` + `PostgresCompatibleSql`로 모은다.
- 컨트롤러 등록은 `QuestionGenerateService.createQuestionWithOracleConversion` 호출만 한다.
- 호출부별 차이는 보존한다: 등록과 가져오기 저장은 `EXECUTABLE`일 때만 `CONCEPT_ONLY`로 바꾸고(`resolveExecutionMode`), 가져오기 검증은 감지한 키워드를 SKIP 사유에 넣는다(`oracleOnlyKeyword`).
- 변환 규칙 자체([[DEC-0046-oracle-sql-translate-or-concept-only]]: 안전한 치환 + 남는 Oracle 전용 문법은 `CONCEPT_ONLY`)는 바꾸지 않았다(구조만 변경).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음. (원본: 서버 전체·아키텍처·계약 테스트 통과.)

**부정**
- 편집(`updateQuestion`)과 검수 후 저장(`createQuestionWithSeedSet`) 경로는 여전히 변환하지 않는다. 원래 동작을 그대로 둔 것이며 의도인지는 확인하지 못했다(리포트 주의사항).

## 영향 범위 (Scope)
서버 `OracleSqlCompatibilityConverter`, `PostgresCompatibleSql`, `QuestionGenerateService`, `AdminQuestionController`, `QuestionImportItemValidator`, `QuestionImportExportService`.

## 출처 (References)
- GitHub #762 리포트 댓글 「변경 사항」·「핵심 구현」·「주의 사항」
- [[ISS-0434-audit-followup-split-large-files-report]]
