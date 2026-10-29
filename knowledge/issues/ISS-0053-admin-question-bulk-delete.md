---
type: issue
id: ISS-0053
created: 2026-04-11
topics: [admin, question-bank]
symptoms: ["일괄 삭제 없음", "/admin/questions", "툴바 버튼 과다", question-checkbox, selectAllCheckbox, "DELETE /admin/questions/bulk"]
root_cause: "체크박스 UI는 있었지만 선택 내보내기에만 쓰였고 일괄 삭제 기능이 없었다. 툴바에 버튼 6개가 한 줄로 나열됐다"
status: resolved
resolution: "[[ISS-0053-admin-question-bulk-delete-report]]"
related: ["[[DEC-0044-bulk-delete-per-item-transaction]]", "[[DEC-0037-question-hard-delete-cascade]]"]
source: "https://github.com/Twin-Fang/passQL/issues/96"
---

# ISS-0053: 관리자 문제 관리에 선택 일괄삭제가 없고 툴바가 과밀

GitHub #96 (원본: 이슈 본문과 댓글).

## 증상
`/admin/questions`에서 삭제는 행별 버튼으로만 된다. 체크박스(`question-checkbox`)와 전체선택(`selectAllCheckbox`)은 선택 내보내기에만 쓰인다. 툴바 버튼(가이드 / JSON 가져오기 / 필터 전체 내보내기 / 선택 내보내기 / 직접 등록 / AI 생성)이 한 줄로 나열돼 가독성이 떨어진다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-11: 리포트 댓글, 스크린샷과 삭제 SQL 로그, "Stable 적용 완료" 댓글.

## 근본 원인
기능 미구현.
