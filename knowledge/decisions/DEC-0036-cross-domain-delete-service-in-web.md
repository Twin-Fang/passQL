---
type: decision
id: DEC-0036
created: 2026-04-10
reviewed: null
topics: [admin, ops-infra]
status: archived
supersedes: null
superseded_by: null
related: ["[[ISS-0038-admin-question-delete-json-loader]]", "[[ISS-0038-admin-question-delete-json-loader-report]]", "[[DEC-0045-multi-domain-aggregation-in-application]]"]
---

# DEC-0036: 문제·제출 도메인을 함께 지우는 삭제 오케스트레이션은 `PQL-Web`의 `AdminQuestionDeleteService`에 둔다

## 문제 정의 (Context)
문제 삭제는 `PQL-Domain-Question`과 `PQL-Domain-Submission` 양쪽 테이블을 지워야 했다 (GitHub #58).

## 결정 (Decision)
양쪽 도메인 모듈의 Repository를 모두 주입받을 수 있는 `PQL-Web` 모듈에 `AdminQuestionDeleteService`를 둔다.

## 검토한 대안 (Alternatives)
- `QuestionService`(`PQL-Domain-Question`)에 `SubmissionRepository`(`PQL-Domain-Submission`)를 직접 주입: 리포트는 순환 의존(`Question → Submission → Question`)이 생겨 피했다고 적었다.
- `PQL-Application` 모듈 배치: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 순환 의존 없이 양쪽 Repository를 쓴다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`server/PQL-Web/.../service/AdminQuestionDeleteService.java`, `AdminQuestionController`. GitHub #96 일괄삭제도 이 서비스를 확장했다.

## 출처 (References)
- GitHub #58 이슈 본문, `## 개요` 리포트 댓글 「크로스 모듈 의존성 해결」(2026-04-10)
