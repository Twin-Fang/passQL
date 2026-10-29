---
type: issue
id: ISS-0049
created: 2026-04-11
topics: [question-bank, admin]
symptoms: [question-register-guide.md, question-bulk-guide.md, "schemaDisplay 누락", ODD_ONE_OUT, CONCEPT_ONLY, "stem에 보기 포함", "schemaDdl 누락", "AI 변환 프롬프트"]
root_cause: "단건·벌크 등록 가이드의 AI 변환 프롬프트가 최소 수준이라 외부 AI가 만든 JSON 품질이 일정하지 않았다 (schemaDisplay 누락, 유형 안내·예시 부족)"
status: resolved
resolution: "[[ISS-0049-question-register-guide-ai-prompt-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/89"
---

# ISS-0049: 문제 등록 가이드라인과 AI 변환 프롬프트가 부실해 생성 JSON 품질이 들쭉날쭉

GitHub #89 (원본: 이슈 본문과 댓글).

## 증상
외부 AI로 문제 JSON을 만들면 stem 품질 저하, `schemaDdl` 누락, `answerSql` 오류가 생긴다. `schemaDisplay`가 JSON 스키마에서 빠져 있다. ODD_ONE_OUT·CONCEPT_ONLY 안내와 JSON 예시가 없고 MariaDB/Oracle 호환 SQL 기준이 불명확하다.

## 재현 조건
가이드의 AI 변환 프롬프트로 문제 JSON 생성.

## 조사 기록
- 2026-04-11: 리포트 댓글.

## 근본 원인
가이드·프롬프트가 필드·유형·예시를 충분히 정의하지 않았다.
