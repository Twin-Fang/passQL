---
type: completion-report
id: ISS-0037
created: 2026-04-10
topics: [practice]
status: resolved
resolves: "[[ISS-0037-submit-404-execution-mode-null]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/57"
---

# ISS-0037 완료 리포트: `SubmitRequest` DTO 도입과 AI 검수 경로 `CONCEPT_ONLY` 기본값

GitHub #57 `## 개요` 리포트 댓글(2026-04-10, 백엔드)과 프론트 작업 댓글(2026-04-10) 기준.

## 해결 방법
- `SubmitRequest.java` 신규: `@Schema`로 `selectedChoiceKey`를 명시. `QuestionController.submit`의 `@RequestBody Map<String, String>`을 교체하고 기존 `selectedKey` fallback 로직 제거. `QuestionControllerDocs` 동기화.
- `QuestionGenerateService.createQuestionWithSeedSet()`에 `.executionMode(ExecutionMode.CONCEPT_ONLY)` 추가.
- 프론트: `client/src/types/api.ts`의 `QuestionSummary`·`QuestionDetail` `executionMode`를 `ExecutionMode | null`로 변경. `npm run build` 통과.
- submit 404 자체는 코드 수정 없음 — 백엔드 재배포로 해결한다고 적혀 있다.

## 근본 원인 (확정)
이슈 노트 「근본 원인」과 같다.

## 재발 방지
리포트 주의사항: 기존 DB의 null `execution_mode`는 별도 Flyway 마이그레이션(`UPDATE question SET execution_mode = 'CONCEPT_ONLY' WHERE execution_mode IS NULL`)으로 보정이 필요하다 — 실행 여부는 원본에 적혀 있지 않다. 레거시 `selectedKey` 필드명 요청은 더 이상 지원되지 않는다.

## 교훈
(원본에 없음, 볼트 정리) 문제 생성 경로가 여럿이면 기본값 설정이 경로마다 같은지 확인한다.
