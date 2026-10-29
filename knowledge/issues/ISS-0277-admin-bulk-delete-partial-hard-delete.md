---
type: issue
id: ISS-0277
created: 2026-10-15
topics: [admin, question-bank]
symptoms: [문제 일괄 삭제, 부분 실패, "REQUIRES_NEW 미적용", self-invocation, "회원 제출 기록 영구 삭제", 실행 로그 삭제, question_report]
root_cause: "같은 클래스 메서드 직접 호출이라 `@Transactional(REQUIRES_NEW)`가 적용되지 않아 부분 삭제됐고, 삭제가 회원 제출 기록·실행 로그까지 영구 삭제했다"
status: resolved
resolution: "[[ISS-0277-admin-bulk-delete-partial-hard-delete-report]]"
related: ["[[DEC-0127-question-delete-as-deactivation]]", "[[ISS-0285-admin-menu-search-filter-status]]"]
source: "https://github.com/Twin-Fang/passQL/issues/471"
---

# ISS-0277: 관리자 문제 일괄 삭제가 부분 실패하고 회원 기록까지 영구 삭제

GitHub #471 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 같은 클래스 메서드 직접 호출이라 `@Transactional(REQUIRES_NEW)`가 적용되지 않음. 중간 실패 시 일부만 삭제.
- 삭제 시 회원 제출 기록과 실행 로그도 영구 삭제.
- `question_report`는 정리하지 않아 삭제된 문제의 신고 상세가 실패할 수 있음(원본: 확인 필요).
- 위치: `server/PQL-Web/.../service/AdminQuestionDeleteService.java:52-53,105,123`.

## 재현 조건
관리자 문제 일괄 삭제 중 한 건이 실패할 때(부분 삭제), 또는 제출 기록이 있는 문제를 삭제할 때(회원 기록 소실).

## 조사 기록
- 2026-10-15: 이슈 본문 예상 동작 — 기본 동작을 비활성화(soft delete)로 변경해 회원 기록 보존, 영구 삭제가 필요하면 별도 빈으로 트랜잭션 보장.

## 근본 원인
frontmatter `root_cause`와 같음.
