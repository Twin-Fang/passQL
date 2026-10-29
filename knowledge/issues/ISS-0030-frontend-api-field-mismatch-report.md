---
type: completion-report
id: ISS-0030
created: 2026-04-09
topics: [dev-workflow, practice]
status: resolved
resolves: "[[ISS-0030-frontend-api-field-mismatch]]"
related: ["[[DEC-0031-frontend-follows-backend-spec-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/41"
---

# ISS-0030 완료 리포트: AI payload를 백엔드 camelCase로 맞추고 미지원 코드 제거, 카테고리 Practice·3D 통계 추가

GitHub #41 프론트 담당 작업 보고 댓글(2026-04-09) 기준. 보고서 파일 `.report/20260410_#41_프론트_백엔드_API_매핑_불일치_수정_및_카테고리_Practice_구현.md` 언급.

## 해결 방법
- API 매핑: `src/types/api.ts`에서 `ExplainErrorPayload.error_message` → `errorMessage`, `DiffExplainPayload.question_id`(number) → `questionUuid`(string), `selected_key` → `selectedChoiceKey`, `SubmitPayload`의 `choiceSetId` 제거, 미사용 SSE 타입 제거. `src/api/ai.ts`·`questions.ts` body camelCase, `generateChoices()` 삭제. 이유: "프론트는 백엔드 스펙만 따름".
- 홈: greeting·오늘의 문제·추천·시험 일정 4개 API 연동, 30일 히트맵 캘린더, 오답 시 유사 문제 추천.
- 카테고리 Practice: `CategoryCards.tsx`(필터 드롭다운 → 카드 그리드), `practiceStore.ts`(`submitAndAdvance` 단일 `set()`), `src/api/practice.ts`(첫 문제 즉시 + 9문제 점진 추가, practice 엔드포인트 자동 mock fallback), `PracticeSet.tsx`, 3스텝 `PracticeResult.tsx`. 문제 전환 리렌더 4~5회 → 1회.
- 통계: `Stats3DChart.tsx`(Three.js r183, `three` `0.183.2`), `Stats2DChart.tsx`, 2D/3D 토글.
- 브랜딩: 로고, `favicon.svg` → `favicon.png`.
- 코드 품질: 문제 생성 실패 에러 배너, mock miss `console.warn`에 `IS_DEV` 가드.
- 검증: `npm run build`, `npx vitest run` 8 파일 98 테스트 통과, Vercel 배포, 코드리뷰 CRITICAL 0 / HIGH 3.

## 근본 원인 (확정)
프론트가 AI 서버 스펙을 직접 따라 백엔드 프록시 스펙과 어긋났다 (이슈 본문·리포트).

## 재발 방지
리포트 참고사항: `/practice/generate`, `/practice/submit`, `/progress/categories`는 백엔드 미확정이라 mock으로 동작 — 확정 시 `practiceFetch` fallback 제거. mock에서 정답이 선택지 "A"로 하드코딩(`PracticeSet.tsx:37`) — 실제 API 연동 시 백엔드가 판별.

## 교훈
(원본에 없음, 볼트 정리) AI 기능 호출이 400/null로 실패하면 프론트 payload가 AI 서버(snake_case) 스펙이 아니라 Spring 프록시(camelCase) 스펙을 따르는지부터 본다.
