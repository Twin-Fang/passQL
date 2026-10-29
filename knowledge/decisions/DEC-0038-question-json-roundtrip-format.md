---
type: decision
id: DEC-0038
created: 2026-04-10
reviewed: null
topics: [admin, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0039-bulk-question-json-import-export]]", "[[ISS-0039-bulk-question-json-import-export-report]]"]
---

# DEC-0038: 문제 JSON 내보내기·가져오기는 `questionUuid` 유무로 신규/업데이트를 가르고, 토픽은 `topicUuid` 대신 `topicCode`로 쓴다

## 문제 정의 (Context)
관리자 문제를 대량으로 내보내고 다시 가져오는 JSON 포맷을 정해야 했다 (GitHub #60).

## 결정 (Decision)
- 내보내기 JSON에 `questionUuid`를 포함한다. 가져올 때 있으면 기존 문제 업데이트, 없으면 신규 등록. uuid를 지우면 복제·이관 용도로 쓸 수 있다.
- 토픽은 `topicUuid` 대신 `topicCode`로 표현한다.
- 가져오기는 검증(`/import/validate`) → 결과 모달 → 등록(`/import`) 2단계이고, "전체 등록" 또는 "성공한 것만 등록"을 고른다.

## 검토한 대안 (Alternatives)
- `topicUuid` 사용: 리포트는 "`topicUuid` 대신 `topicCode`를 사용하여 환경 간 이식성을 확보했다"고 적었다.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 환경 간 이식성, 같은 파일로 라운드트립 업데이트 가능, 기존 단건 JSON 스키마와 하위 호환.

**부정**
- 내보내기 최대 500건, 가져오기 최대 100건.

## 영향 범위 (Scope)
`QuestionExportDto`, `QuestionImportExportService`, `AdminQuestionController` export/import 엔드포인트, `question-import-export.js`.

## 출처 (References)
- GitHub #60 이슈 본문 「해결 방안」, `## 개요` 리포트 댓글 「JSON 내보내기/가져오기 라운드트립」(2026-04-10)
