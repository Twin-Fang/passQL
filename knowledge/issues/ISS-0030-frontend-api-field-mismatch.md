---
type: issue
id: ISS-0030
created: 2026-04-09
topics: [dev-workflow, practice]
symptoms: [diffExplain, explainError, snake_case, camelCase, question_id, error_message, choiceSetId, generateChoices, "AI 호출 실패"]
root_cause: "프론트가 AI 서버(FastAPI) 스펙(snake_case)을 직접 따르고 있어 백엔드(Spring) 프록시 camelCase 스펙과 맞지 않았다"
status: resolved
resolution: "[[ISS-0030-frontend-api-field-mismatch-report]]"
related: ["[[DEC-0031-frontend-follows-backend-spec-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/41"
---

# ISS-0030: 프론트-백엔드 API 매핑 불일치 프론트 수정

GitHub #41 (원본: 이슈 본문과 댓글).

## 증상
프론트·백엔드·AI 서버 3계층 전수 분석에서 확인된 불일치:
1. `diffExplain`(CRITICAL): 프론트 `question_id: number`, `selected_key` vs 백엔드 `questionUuid: string`, `selectedChoiceKey` → 호출 시 무조건 실패.
2. `explainError`(HIGH): 프론트 `error_message` vs 백엔드 `errorMessage` → Jackson 기본 camelCase라 키가 무시되어 null로 역직렬화.
3. `submitAnswer`(MEDIUM): 백엔드 미지원 `choiceSetId` 전송, `generateChoices` SSE 엔드포인트(`POST /questions/{questionUuid}/generate-choices`)는 백엔드에 없음.

## 재현 조건
프론트에서 `diffExplain` 호출 → 실패. `explainError` 호출 → 백엔드에서 `errorMessage`가 null (이슈 본문).

## 조사 기록
- 2026-04-09: 프론트 담당 작업 보고 (아래 리포트). 같은 이슈에서 카테고리 Practice 세트 풀이, Three.js 3D 통계, 브랜딩도 함께 작업했다 (51개 커밋).

## 근본 원인
프론트가 AI 서버(FastAPI) 스펙을 직접 따르고 있었다 (이슈 본문).
