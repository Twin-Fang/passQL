---
type: completion-report
id: ISS-0039
created: 2026-04-10
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0039-bulk-question-json-import-export]]"
related: ["[[DEC-0038-question-json-roundtrip-format]]"]
source: "https://github.com/Twin-Fang/passQL/issues/60"
---

# ISS-0039 완료 리포트: 필터·선택 내보내기, Sandbox 일괄 검증 후 가져오기

GitHub #60 `## 개요` 리포트 댓글(2026-04-10) 기준. 같은 날 스크린샷과 "구현 완료" 댓글.

## 해결 방법
- DTO: `QuestionExportDto`, `ExportRequest`, `ImportValidationResult`, `ImportItemResult`(sandboxStatus OK/FAIL/SKIP, importAction NEW/UPDATE), `ImportRequest`, `ImportResult`.
- `QuestionImportExportService`: `SandboxPool`/`SandboxExecutor`를 재활용해 EXECUTABLE 문제마다 독립 sandbox DB에 DDL+샘플데이터 적용 후 `answerSql` 실행. CONCEPT_ONLY는 SKIP.
- 엔드포인트: `GET /admin/questions/export`, `POST /admin/questions/export`, `POST /admin/questions/import/validate`, `POST /admin/questions/import`.
- `QuestionRepository.findByFiltersAll()`(최대 500건). `ErrorCode`에 `IMPORT_LIMIT_EXCEEDED`(최대 100건), `EXPORT_NO_DATA`.
- `questions.html` 체크박스·버튼·검증 결과 모달, `question-import-export.js` 신규(escapeHtml 포함).
- 등록 시 Sandbox를 다시 돌리지 않고 프론트가 보낸 `sandboxStatuses`로 FAIL만 스킵. null이거나 개수가 안 맞으면 전체 스킵.
- N+1 방지: 토픽 매핑을 한 번에 조회해 Map 캐싱.

## 근본 원인 (확정)
기능 미구현.

## 재발 방지
리포트 주의사항: Sandbox 검증은 문제별로 DB를 생성·삭제해 100건 기준 약 100초가 걸릴 수 있다. 기존 단건 JSON 스키마와 하위 호환. 단건용 `question-json-loader.js`와 배치용 `question-import-export.js`는 별도 파일.

## 교훈
논의 기록 없음.
