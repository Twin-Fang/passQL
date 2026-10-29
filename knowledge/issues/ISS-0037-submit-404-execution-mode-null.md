---
type: issue
id: ISS-0037
created: 2026-04-10
topics: [practice]
symptoms: [submit, "404 Not Found", additionalProp1, "Map<String, String>", "executionMode null", "항상 오답 표시", "실행 버튼 숨김"]
root_cause: "submit 404는 프로덕션 배포 누락(리포트 판단). Swagger 스키마 오류는 @RequestBody Map 사용, executionMode null은 AI 검수 경로 createQuestionWithSeedSet()이 값을 설정하지 않음"
status: resolved
resolution: "[[ISS-0037-submit-404-execution-mode-null-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/57"
---

# ISS-0037: submit 엔드포인트 404와 `executionMode` null

GitHub #57 (원본: 이슈 본문과 댓글).

## 증상
1. `POST <API 서버>/api/questions/{questionUuid}/submit`이 프로덕션에서 404. Swagger의 요청 바디 스키마가 `additionalProp1/2/3`으로 표시된다. 프론트는 404를 잡으면 `isCorrect: false`로 폴백해 **항상 오답**으로 보인다.
2. `GET /questions/{questionUuid}` 응답의 `executionMode`가 `null`. 프론트는 이 값으로 SQL 실행 버튼을 결정하므로 실행 버튼이 숨고 선택지 자동 execute가 동작하지 않는다.

## 재현 조건
프로덕션에서 문제 풀이 제출. AI 검수 경로로 생성된 문제 상세 조회.

## 조사 기록
- 2026-04-10: 백엔드 리포트 — submit 코드에는 이상이 없고 배포 누락 가능성이 높다고 판단. `Map` 바디는 OpenAPI에서 `additionalProperties`로 표시된다.
- 2026-04-10: 프론트 점검 — `submitAnswer()`는 이미 `selectedChoiceKey`·`X-Member-UUID`로 올바르게 호출 중. `null === "EXECUTABLE"`이 false라 런타임은 CONCEPT_ONLY처럼 동작하지만 타입이 null을 허용하지 않았다.

## 근본 원인
- submit 404: 리포트는 프로덕션 배포 누락으로 판단(재배포 후 재확인 필요라고 적음).
- Swagger 스키마: `@RequestBody Map<String, String>`.
- `executionMode` null: 문제 생성 경로 두 개 중 `createQuestionWithSeedSet()`(AI 검수 저장)만 `executionMode`를 설정하지 않았다(`createQuestionOnly()`는 `EXECUTABLE` 기본값).
