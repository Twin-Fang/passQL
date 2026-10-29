---
type: issue
id: ISS-0285
created: 2026-10-15
topics: [admin]
symptoms: [관리자 문제 검색 없음, 활성 여부 필터 없음, 건의 상태 필터 없음, 신고 페이지네이션 없음, 기각 처리 없음, 토픽 생성 없음, 회원 탈퇴 처리 없음]
root_cause: "관리 메뉴에 검색·필터·처리 상태 기능이 비어 있었다(기능 공백)"
status: resolved
resolution: "[[ISS-0285-admin-menu-search-filter-status-report]]"
related: ["[[ISS-0277-admin-bulk-delete-partial-hard-delete]]", "[[DEC-0127-question-delete-as-deactivation]]"]
source: "https://github.com/Twin-Fang/passQL/issues/479"
---

# ISS-0285: 관리 메뉴의 빈 기능 (검색, 필터, 처리 상태)

GitHub #479 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 문제: 본문 검색, 활성 여부 필터 없음.
- 건의: 상태 필터, 답변, 회원 링크 없음.
- 신고: 페이지네이션, 기각 처리 없음.
- 토픽 생성, 시험 일정 수정, 개념 문서 삭제 없음.
- 회원: 탈퇴 처리, 역할 변경 없음.
- 위치: `AdminQuestionController.java:49-56`, `AdminFeedbackController`, `AdminReportController.java:28`, `AdminTopicController`, `AdminExamScheduleController`.

## 재현 조건
해당 없음(기능 개선). 제안: 운영 빈도 순으로 보강.

## 조사 기록
- 2026-10-15: 구현 중 기존 버그 2건 발견 — 토픽 추가 폼이 매핑되지 않은 경로로 전송, 코드 입력 패턴이 실제 형식(소문자)과 다름.

## 근본 원인
frontmatter `root_cause`와 같음.
