---
type: issue
id: ISS-0039
created: 2026-04-10
topics: [admin, question-bank]
symptoms: ["/admin/questions", "JSON 일괄 내보내기 없음", "JSON 가져오기 단건만", "answerSql 사전 검증 불가", Sandbox]
root_cause: "질문 관리 목록에 일괄 내보내기·가져오기가 없었고, JSON 불러오기는 직접 등록 페이지 단건만 지원했다"
status: resolved
resolution: "[[ISS-0039-bulk-question-json-import-export-report]]"
related: ["[[DEC-0038-question-json-roundtrip-format]]"]
source: "https://github.com/Twin-Fang/passQL/issues/60"
---

# ISS-0039: 질문 관리에 대량 JSON 내보내기·가져오기와 Sandbox 일괄 검증이 없음

GitHub #60 (원본: 이슈 본문과 댓글).

## 증상
`/admin/questions`에서 문제를 일괄 내보내기·가져오기할 방법이 없다. JSON 불러오기는 `/admin/questions/register`에서 단건만 지원해 대량 등록 시 하나씩 불러와야 한다. 가져올 때 EXECUTABLE 문제의 `answerSql`이 실제로 실행되는지 사전 검증할 수 없다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-04-10: 설계 문서 `docs/superpowers/specs/2026-04-10-bulk-json-import-export-design.md`. Entity/DB 스키마 변경 없음.
- 2026-04-10: 리포트 댓글, 스크린샷과 "구현 완료" 댓글.

## 근본 원인
기능 미구현.
