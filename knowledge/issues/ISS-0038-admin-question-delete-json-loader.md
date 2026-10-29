---
type: issue
id: ISS-0038
created: 2026-04-10
topics: [admin, question-bank]
symptoms: ["관리자 문제 삭제 없음", "수정 폼 JSON 불러오기 없음", QUESTION_IN_ACTIVE_SESSION, question-json-loader.js, "_method=delete"]
root_cause: "관리자 문제 관리에 삭제 API·UI와 수정 폼 JSON 불러오기가 구현되어 있지 않았다"
status: resolved
resolution: "[[ISS-0038-admin-question-delete-json-loader-report]]"
related: ["[[DEC-0036-cross-domain-delete-service-in-web]]", "[[DEC-0037-question-hard-delete-cascade]]"]
source: "https://github.com/Twin-Fang/passQL/issues/58"
---

# ISS-0038: 관리자 문제 삭제와 수정 폼 JSON 불러오기 기능 누락

GitHub #58 (원본: 이슈 본문과 댓글).

## 증상
관리자 문제 관리 화면에 문제 삭제 기능이 없고, 수정 폼(`question-edit.html`)에는 등록 폼에 있는 JSON 불러오기가 없었다. 이슈 본문은 증상보다 작업 계획(삭제 안전장치, 삭제 UI, JSON 로직 공통 추출)을 적었다.

## 재현 조건
해당 없음 (기능 누락).

## 조사 기록
- 2026-04-10: 이슈 본문에 설계 문서 `docs/superpowers/specs/2026-04-10-admin-question-crud-design.md`, 계획 `docs/superpowers/plans/2026-04-10-admin-question-delete-json-loader.md`. 범위 밖: Soft delete, 벌크 삭제, 삭제 복원, 감사 로그.
- 2026-04-10: 리포트 댓글, "정상 삭제 작동 확인" 댓글.

## 근본 원인
기능 미구현.
