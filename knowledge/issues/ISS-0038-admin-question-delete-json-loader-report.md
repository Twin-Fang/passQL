---
type: completion-report
id: ISS-0038
created: 2026-04-10
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0038-admin-question-delete-json-loader]]"
related: ["[[DEC-0036-cross-domain-delete-service-in-web]]", "[[DEC-0037-question-hard-delete-cascade]]"]
source: "https://github.com/Twin-Fang/passQL/issues/58"
---

# ISS-0038 완료 리포트: 문제 Cascade 삭제와 수정 폼 JSON 불러오기 공통화

GitHub #58 `## 개요` 리포트 댓글(2026-04-10) 기준. 같은 날 "정상 삭제 작동 확인" 댓글.

## 해결 방법
- `ErrorCode`에 `QUESTION_IN_ACTIVE_SESSION(HttpStatus.CONFLICT)`. `PQL-Web/service/AdminQuestionDeleteService.java` 신규, `AdminQuestionController`에 `@DeleteMapping("/{uuid}")`(flash 메시지).
- `application.yml`에 `spring.mvc.hiddenmethod.filter.enabled: true` — HTML form의 `_method=delete`가 `@DeleteMapping`으로 라우팅되도록. 기존 `prompts.html`의 `th:method="put"`도 이 설정에 의존.
- 리포지토리 벌크 삭제 메서드 6개(`QuizSessionRepository.findByStatus`, `deleteByQuestionUuid` 등).
- 삭제 순서: IN_PROGRESS 세션 검사(409) → ExecutionLog → Submission → DailyChallenge → QuestionConceptTag → QuestionChoiceSetItem → QuestionChoiceSet → QuestionChoice → Question, 단일 `@Transactional`.
- `question-json-loader.js` 신규(`applyJson`, `loadJsonFile`, `openJsonPasteModal`, `applyJsonFromPaste`, `initQuestionJsonLoader({ confirmOverwrite })`). `question-register.html`은 공통 JS로 교체, `question-edit.html`에 불러오기·붙여넣기와 덮어쓰기 확인.

## 근본 원인 (확정)
기능 미구현.

## 재발 방지
리포트 주의사항: 활성 세션 검사는 `questionOrderJson`에 대한 `String.contains(uuid)` 문자열 검색이다(엄밀한 JSON 파싱 아님). Hard delete라 관련 Submission·ExecutionLog가 함께 지워진다.

## 교훈
(원본에 없음, 볼트 정리) HTML form의 DELETE/PUT이 라우팅되지 않으면 `HiddenHttpMethodFilter` 활성화 여부를 먼저 본다.
