---
type: decision
id: DEC-0037
created: 2026-04-10
reviewed: null
topics: [admin, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0038-admin-question-delete-json-loader]]", "[[ISS-0038-admin-question-delete-json-loader-report]]", "[[ISS-0053-admin-question-bulk-delete]]"]
---

# DEC-0037: 관리자 문제 삭제는 자식 테이블까지 Hard delete, 진행 중 퀴즈 세션이 쓰는 문제는 409로 거부

## 문제 정의 (Context)
관리자 문제 관리에 삭제 기능이 없었다 (GitHub #58).

## 결정 (Decision)
- 문제 삭제는 Hard delete. 8개 자식 테이블을 FK 역순(ExecutionLog → Submission → DailyChallenge → QuestionConceptTag → QuestionChoiceSetItem → QuestionChoiceSet → QuestionChoice → Question)으로 단일 트랜잭션에서 지운다.
- IN_PROGRESS `QuizSession`이 그 문제를 쓰고 있으면 `QUESTION_IN_ACTIVE_SESSION`(409)으로 거부한다.

## 검토한 대안 (Alternatives)
- Soft delete: 이슈 본문과 리포트 모두 "범위 밖"으로 뺐다. 리포트는 "운영 초기이므로 현재는 적절하나, 향후 사용자 학습 이력 보존이 중요해지면 Soft delete 전환을 검토해야 한다"고 적었다.

## 결과 (Consequences)
**긍정**
- 단일 트랜잭션이라 어느 단계에서 실패하든 전체 롤백된다.

**부정**
- 관련 Submission·ExecutionLog(학습 이력)가 함께 삭제된다.
- 활성 세션 검사는 `String.contains(uuid)` 문자열 검색이다.

## 영향 범위 (Scope)
`AdminQuestionDeleteService`, 6개 리포지토리의 벌크 삭제 메서드, `ErrorCode.QUESTION_IN_ACTIVE_SESSION`.

## 출처 (References)
- GitHub #58 이슈 본문 「범위 밖」, `## 개요` 리포트 댓글 「Cascade 삭제 순서」·「주의사항」(2026-04-10)
