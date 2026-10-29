---
type: decision
id: DEC-0127
created: 2026-10-15
reviewed: null
topics: [admin, question-bank]
status: active
supersedes: DEC-0037
superseded_by: null
related: ["[[ISS-0277-admin-bulk-delete-partial-hard-delete]]", "[[ISS-0285-admin-menu-search-filter-status]]", "[[DEC-0037-question-hard-delete-cascade]]"]
---

# DEC-0127: 관리자 문제 삭제(단건·일괄)는 `isActive` 비활성화로 하고 영구 삭제는 없앤다

## 문제 정의 (Context)
일괄 삭제가 `REQUIRES_NEW` 미적용으로 부분 실패했고, 삭제가 회원 제출 기록과 실행 로그까지 영구 삭제했다 (GitHub #471).

## 결정 (Decision)
- 단건·일괄 삭제 모두 `isActive`를 끄는 비활성화. 제출 기록, 실행 로그, 신고, 데일리 이력, 선택지는 보존.
- 영구 삭제 코드는 제거. 일괄 처리는 한 트랜잭션에서 상태만 바꾼다.
- 없는 문제·이미 비활성인 문제는 건너뛰고 사유를 돌려준다.
- 되살리기는 문제 목록·상세의 복구 버튼(GitHub #479).

## 검토한 대안 (Alternatives)
- 이슈 본문은 "영구 삭제가 필요하면 별도 빈으로 트랜잭션 보장, 신고 데이터도 함께 처리"를 함께 제안했으나, 구현 보고서는 영구 삭제 코드를 제거했다. 영구 삭제를 남기지 않은 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 회원 기록 보존, 일괄 처리 부분 실패 없음.

**부정**
- ErrorCode `QUESTION_IN_ACTIVE_SESSION`은 쓰이지 않지만 앱·웹 계약이라 남아 있다.

## 영향 범위 (Scope)
`AdminQuestionDeleteService`, 관리자 문제 목록·상세 화면 문구, 문제 조회 시 활성 여부 필터(GitHub #479).

## 출처 (References)
- GitHub #471 이슈 본문, 구현 보고서 댓글(2026-10-15)
- [[ISS-0277-admin-bulk-delete-partial-hard-delete]]
