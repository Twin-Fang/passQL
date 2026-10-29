---
type: completion-report
id: ISS-0285
created: 2026-10-15
topics: [admin]
status: resolved
resolves: "[[ISS-0285-admin-menu-search-filter-status]]"
related: ["[[ISS-0277-admin-bulk-delete-partial-hard-delete]]", "[[DEC-0127-question-delete-as-deactivation]]"]
source: "https://github.com/Twin-Fang/passQL/issues/479"
---

# ISS-0285 완료 리포트: 문제 검색·활성 필터·복구, 건의·신고 처리 상태, 토픽·일정·개념·회원 관리 보강

GitHub #479 구현 보고서 댓글 기준 (3차 통합 main `c46b9e6`, 0.13.0).

## 해결 방법
- 문제: 지문 검색, 활성 여부 필터(기본 활성만), 목록·상세의 복구 버튼(GitHub #471로 삭제가 비활성화가 된 것의 짝). 복구 시 추천 색인 재적재.
- 건의: 상태 필터, 회원 링크, 관리자 메모(마이그레이션 `V0_10_12`).
- 신고: 페이지네이션, 기각(`DISMISSED`), 회원 링크.
- 토픽·서브토픽 추가, 시험 일정 수정, 개념 문서 삭제, 회원 탈퇴 처리(삭제 사유 `ADMIN_WITHDRAW`).
- 함께 고친 기존 버그: 토픽 추가 폼의 매핑되지 않은 경로, 코드 입력 패턴(소문자).
- 검증: 서버 전체 108개 중 107개 통과, 운영 관리자 화면 200·콘솔 오류 0.

## 근본 원인 (확정)
기능 공백(버그 아님). 함께 고친 버그 2건의 원인은 위와 같다.

## 재발 방지
주의(원본): `/admin/api/reports` 응답이 목록에서 페이지 객체로 바뀌었다. 이 API는 관리자 신고 화면만 쓴다.

## 교훈
원본에 없음.
