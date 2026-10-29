---
type: completion-report
id: ISS-0057
created: 2026-04-11
topics: [practice, progress-stats, home]
status: resolved
resolves: "[[ISS-0057-fe-hardcoded-analysis-to-api]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/101"
---

# ISS-0057 완료 리포트: AI 코멘트 실연동, 데일리 챌린지 페이지, 버전 단일 소스

GitHub #101 프론트 작업 댓글(2026-04-11) 기준.

## 해결 방법
- `src/pages/PracticeResult.tsx`: 하드코딩 분석 텍스트 → `fetchAiComment()` + `useQuery`, skeleton·graceful 숨김. `staleTime: 1000 * 60 * 60 * 24`(Redis 24h 캐시에 맞춤). `useEffect + cancelled` 대신 `useQuery`(StrictMode 중복 요청 제거).
- `src/pages/DailyChallenge.tsx`, `src/App.tsx`: `/daily-challenge` 라우트 신설 — 이미 풀었으면 홈 리디렉션, 문제 없으면 안내, 제출 후 `isDailyChallenge: true`로 결과 페이지.
- `QuestionDetail.tsx`에 `onSubmitSuccess(result, questionUuid)` prop, `AnswerFeedback.tsx`에 `isDailyChallenge` 분기(정답 → 홈, 오답 → 다시 풀기).
- `Home.tsx`: `alreadySolvedToday`면 완료 라벨·opacity·클릭 비활성.
- `vite.config.ts`: `package.json` 버전을 `__APP_VERSION__`으로 주입(`import.meta.url` 기준 경로), `package.json` 버전 `0.0.0 → 1.0.0`.
- `docs/be-api-docs.json`, `.claude/rules/api-guide.md`: `generateChoices`, `choiceSetId`, `/progress/topic-analysis`, `/progress/ai-comment`, `SubmitResult` 비교 필드 반영.
- 검증: 데일리 챌린지·홈 완료 상태·AI 코멘트 수동 테스트.

## 근본 원인 (확정)
실 API 미연동.

## 재발 방지
작업 댓글: `be-api-docs.json`은 배포된 백엔드 스펙이므로 프론트 단독으로 바꾸지 않는다. CONCEPT_ONLY 문제의 실행 비교 필드는 null(`| null` 타입 반영).

## 교훈
논의 기록 없음.
