---
type: decision
id: DEC-0044
created: 2026-04-11
reviewed: null
topics: [admin, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0053-admin-question-bulk-delete]]", "[[ISS-0053-admin-question-bulk-delete-report]]", "[[DEC-0037-question-hard-delete-cascade]]"]
---

# DEC-0044: 문제 일괄삭제는 건별 독립 트랜잭션으로 지우고, 실패한 건은 건너뛴 채 나머지를 계속한다

## 문제 정의 (Context)
체크박스로 고른 문제를 한 번에 지우는 일괄삭제를 추가하면서, 일부 건이 실패할 때 전체를 어떻게 처리할지 정해야 했다 (GitHub #96).

## 결정 (Decision)
`bulkDeleteQuestions`는 트랜잭션 없이 반복하고, 내부 `deleteSingleInNewTransaction`이 `REQUIRES_NEW`로 문제마다 독립 커밋한다. 예외(JPA 예외 포함)가 난 건은 skipped로 처리하고 나머지 삭제를 계속한다. 응답은 `deleted`, `skipped`, `errors`.

## 검토한 대안 (Alternatives)
- 단일 `@Transactional` 안에서 반복 삭제: 리포트는 한 건이 예외를 던지면 전체가 롤백되므로 피했다고 적었다.

## 결과 (Consequences)
**긍정**
- 한 건 실패가 다른 건 롤백에 영향을 주지 않는다. 활성 세션에서 쓰는 문제는 건너뛰고 나머지는 지운다.

**부정**
- 일괄삭제가 부분 성공으로 끝날 수 있다(결과의 `skipped`·`errors`로 확인).

## 영향 범위 (Scope)
`AdminQuestionDeleteService`, `AdminQuestionController` `DELETE /admin/questions/bulk`, `question-import-export.js`.

## 출처 (References)
- GitHub #96 `## 개요` 리포트 댓글 「트랜잭션 분리 전략」(2026-04-11)
