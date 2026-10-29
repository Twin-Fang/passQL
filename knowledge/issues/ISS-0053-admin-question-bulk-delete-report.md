---
type: completion-report
id: ISS-0053
created: 2026-04-11
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0053-admin-question-bulk-delete]]"
related: ["[[DEC-0044-bulk-delete-per-item-transaction]]"]
source: "https://github.com/Twin-Fang/passQL/issues/96"
---

# ISS-0053 완료 리포트: `DELETE /admin/questions/bulk`와 툴바 드롭다운 정리

GitHub #96 `## 개요` 리포트 댓글(2026-04-11) 기준. 같은 날 "Stable 적용 완료" 댓글.

## 해결 방법
- `AdminQuestionController`: `DELETE /admin/questions/bulk` — UUID 목록 JSON body를 받아 결과(`deleted`, `skipped`, `errors`) 반환.
- `AdminQuestionDeleteService`: `bulkDeleteQuestions(List<UUID>)`(순차 반복, 예외는 skipped), `deleteSingleInNewTransaction(UUID)`(`@Transactional(propagation = REQUIRES_NEW)`), `BulkDeleteResult` record. 삭제 순서는 기존 `deleteQuestionCascade` 재사용.
- `question-import-export.js`: `updateExportButtonState()`가 선택 삭제 버튼 상태도 갱신, `deleteSelected()`, `confirmBulkDelete()`(`resp.ok`를 `resp.json()` 전에 확인해 HTML 에러 응답 파싱 오류 방지, 실패 시 버튼 복구).
- `questions.html`: JSON 가져오기·필터 전체 내보내기·선택 내보내기·가이드를 `dropdown` 하나로 통합, 선택 삭제 버튼(미선택 시 `disabled`), `bulkDeleteModal`(활성 세션 사용 문제는 건너뜀 안내).

## 근본 원인 (확정)
기능 미구현.

## 재발 방지
리포트 주의사항: `BulkDeleteResult`가 서비스 inner type이라 `AdminQuestionDeleteService.BulkDeleteResult`로 참조한다(dto 패키지 분리 권장). 완료·취소된 `QuizSession`의 `questionOrderJson`에는 삭제된 UUID가 남는다.

## 교훈
(원본에 없음, 볼트 정리) 관리자 fetch에서 서버가 HTML 에러 페이지를 돌려줄 수 있으면 `resp.ok`를 JSON 파싱보다 먼저 본다.
