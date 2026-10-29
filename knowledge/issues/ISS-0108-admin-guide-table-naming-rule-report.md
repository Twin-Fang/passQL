---
type: completion-report
id: ISS-0108
created: 2026-04-12
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0108-admin-guide-table-naming-rule]]"
related: ["[[DEC-0067-short-meaningful-table-names]]"]
source: "https://github.com/Twin-Fang/passQL/issues/193"
---

# ISS-0108 완료 리포트: 가이드 MD·관리자 모달·AI 변환 프롬프트에 테이블 이름 규칙

GitHub #193 `## 개요` 리포트 댓글 기준 (2026-04-12), 같은 날 "Stable 적용" 댓글.

## 해결 방법
- `server/PQL-Web/src/main/resources/static/docs/question-single-guide.md`: `schemaDdl 작성 규칙` 아래 `테이블 이름 작성 규칙 ★` — Sandbox 격리 원리, 나쁜 예/좋은 예, 상황별 권장 이름 표.
- `question-bulk-guide.md`: 같은 규칙(JSON 문자열 예시).
- `templates/admin/question-register.html`, `templates/admin/questions.html`: 가이드 모달에 `⚠️ 테이블 이름 작성 규칙` 섹션(alert + mockup-code), AI 변환 프롬프트의 `schemaDdl 작성:` 항목에 규칙 삽입.
- 규칙 내용: [[DEC-0067-short-meaningful-table-names]].

## 근본 원인 (확정)
가이드에 테이블 이름 지침이 없었다.

## 재발 방지
리포트 주의사항: 기존 등록 문제의 테이블 이름(`SQLD_14` 등)은 자동 수정되지 않는다(필요 시 수동 재등록 또는 DB 직접 수정). AI가 프롬프트 규칙을 반드시 따른다는 보장이 없으니 등록 전 관리자가 JSON의 테이블 이름을 검토하는 것이 바람직.

## 교훈
논의 기록 없음.
