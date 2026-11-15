---
type: decision
id: DEC-0325
created: 2026-11-16
reviewed: null
topics: [question-bank, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0526-question-internal-tags]]", "[[DEC-0324-question-internal-tag-namespace-format]]", "[[DEC-0038-question-json-roundtrip-format]]"]
---

# DEC-0325: 문제 가져오기에서 `internalTags` 칸이 없으면(옛 파일) 갱신 시 기존 태그를 유지하고, `[]`일 때만 전부 지운다

## 문제 정의 (Context)
#1117 이전에 내보낸 문제 JSON에는 `internalTags` 칸이 없다. 이 파일로 기존 문제를 갱신할 때 태그를 어떻게 다룰지 정해야 했다 (GitHub #1117).

## 결정 (Decision)
- `internalTags` 없음(`null`): 신규 문제는 태그 없이 등록, 갱신은 기존 태그 유지.
- `internalTags: []`: 태그 전부 제거.
- 값이 있으면 그 목록으로 교체(규칙 위반 문항은 건너뜀).
- 구현 지점: `QuestionImportExportService.replaceInternalTagsIfPresent`, `QuestionExportDto.internalTags` 주석.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 옛 내보내기 파일을 다시 가져와도 운영 태그(백필 213건 등)가 지워지지 않는다(기존 파일 호환).

**부정**
- 태그를 지우려면 빈 목록을 명시해야 한다. 같은 UUID 재가져오기 때 고정 보기 세트는 통째로 교체되는 것([[DEC-0158-new-questions-concept-only-curated]] 리포트 주의사항)과 동작이 다르다.

## 영향 범위 (Scope)
`QuestionImportExportService`, `QuestionExportDto`, 하네스 가져오기 파일 생성(`import_exporter.py`). 분기를 바꾸면 옛 파일 재가져오기로 운영 태그가 전부 지워질 수 있다.

## 출처 (References)
- GitHub #1117 이슈 본문 「해결 방안」(기존 파일 호환, 갱신 시 교체), 보고서 댓글 「주의 사항」 https://github.com/Twin-Fang/passQL/issues/1117#issuecomment-6903013598, PR #1120 `QuestionExportDto` 주석
