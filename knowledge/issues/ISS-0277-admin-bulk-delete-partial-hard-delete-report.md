---
type: completion-report
id: ISS-0277
created: 2026-10-15
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0277-admin-bulk-delete-partial-hard-delete]]"
related: ["[[DEC-0127-question-delete-as-deactivation]]", "[[ISS-0285-admin-menu-search-filter-status]]"]
source: "https://github.com/Twin-Fang/passQL/issues/471"
---

# ISS-0277 완료 리포트: 문제 삭제를 `isActive` 비활성화로 바꾸고 영구 삭제 코드 제거

GitHub #471 구현 보고서 댓글 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- 단건·일괄 삭제 모두 `isActive`를 끄는 비활성화로 변경. 제출 기록, 실행 로그, 신고, 데일리 이력, 선택지는 보존.
- 영구 삭제 코드 제거. 일괄 처리는 한 트랜잭션에서 상태만 바꿔 부분 실패가 없음.
- 없는 문제·이미 비활성인 문제는 건너뛰고 사유를 돌려줌.
- 관리자 버튼·확인 창·결과 문구를 "비활성화, 회원 기록 보존"으로.
- 검증: `AdminQuestionDeleteServiceTest` 통과, 서버 전체 96개 중 95개 통과(실패 1개는 main에서도 실패하던 dev DB 외래키 문제).

## 근본 원인 (확정)
이슈 본문과 같음 (self-invocation으로 `REQUIRES_NEW` 미적용, 삭제가 회원 기록까지 영구 삭제).

## 재발 방지
삭제 자체를 상태 변경으로 바꿈. 주의(원본): 비활성 문제를 다시 켜는 화면은 GitHub #479에서 추가. 안 쓰게 된 ErrorCode `QUESTION_IN_ACTIVE_SESSION`은 앱·웹 계약이라 남겨 둠.

## 교훈
(원본에 없음, 볼트 정리) 같은 클래스 안에서 호출한 `@Transactional` 메서드는 프록시를 거치지 않아 전파 설정이 무시된다.
