---
type: issue
id: ISS-0061
created: 2026-04-11
topics: [question-bank, practice]
symptoms: ["스키마 보기 미표시", "schema_display NULL", "schemaDisplay 선택 사항", SchemaViewer, question-bulk-guide.md]
root_cause: "가이드라인이 schemaDisplay를 선택 사항으로 표기해 AI 변환 시 생략됐고, 기존 문제의 schema_display가 모두 NULL이었다 (이슈 본문)"
status: resolved
resolution: null
related: ["[[ISS-0062-ai-only-choices-mismatch-question-type]]"]
source: "https://github.com/Twin-Fang/passQL/issues/107"
---

# ISS-0061: 문제 풀이 화면 스키마 미표시와 가이드라인 `schemaDisplay` 필수화

취소로 닫힘: "근본적인 구조 변경 필요 해당 이슈 취소합니다 — #108 해당 이슈에서 처리합니다" (2026-04-11 댓글). GitHub 상태는 completed로 닫혔고 라벨은 `취소`다.

GitHub #107 (원본: 이슈 본문과 댓글).

## 증상
EXECUTABLE 문제 풀이 화면에 "스키마 보기" 버튼이 나오지 않아 테이블 구조를 볼 수 없다. 기존 문제의 `schema_display`가 모두 NULL. `question-bulk-guide.md`, `question-register-guide.md`의 필드 규칙과 AI 변환 프롬프트가 `schemaDisplay`를 선택으로 표기해 AI가 일관되게 누락한다.

## 재현 조건
`schema_display`가 NULL인 EXECUTABLE 문제 풀이 진입.

## 조사 기록
- 2026-04-11: 이슈 본문 제안 — 가이드에서 `schemaDisplay`를 EXECUTABLE 필수로, `SchemaViewer`에 `schemaDdl` 파싱 폴백, 스키마 섹션 노출 조건을 `schemaDisplay || schemaDdl`로 완화. 실행되지 않고 취소됨.

## 근본 원인
이슈 본문 기준 frontmatter `root_cause`와 같다. 취소 댓글은 "근본적인 구조 변경 필요"라고만 적었다.
