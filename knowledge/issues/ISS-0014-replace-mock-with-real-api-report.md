---
type: completion-report
id: ISS-0014
created: 2026-04-08
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0014-replace-mock-with-real-api]]"
related: ["[[DEC-0016-auto-execute-on-choice-click]]"]
source: "https://github.com/Twin-Fang/passQL/issues/13"
---

# ISS-0014 완료 리포트: TanStack Query 훅으로 mock → 실 API 전환, 선택지 실행 캐시, vitest 도입

GitHub #13 프론트 담당 작업 보고 댓글(2026-04-08) 기준, 백엔드 담당 작업 완료 보고(2026-04-22) 보충. 보고서 파일 `.report/20260408_#13_Mock_데이터_실제_API_연동.md` 언급.

## 해결 방법
- 훅: `useProgress`(staleTime 0 / heatmap 5분), `useQuestions`(30초), `useTopics`(Infinity), `useQuestionDetail`(+ `useExecuteChoice`, `useSubmitAnswer`), `useMember`.
- 화면 연동: QuestionDetail은 선택지 클릭 시 SQL 자동 실행 + `Record<choiceKey, ExecuteResult>` 로컬 캐시, submit 결과는 navigate state로 결과 화면에 전달. AnswerFeedback은 state 없으면 `/questions`로 redirect.
- Member: `src/api/members.ts` 신규, `memberStore`에 `ensureRegistered()`(첫 진입 `POST /members/register`, 실패 시 fallback UUID), `App.tsx` 시작 시 호출.
- `AiExplanationSheet`: mock 타이머 제거, `isLoading`/`text` props로 mutation 결과 주입.
- API 문서 동기화: `executeChoice` body `{ choiceKey }` → `{ sql }`(백엔드 실제 스펙).
- 성능: StarRating·ChoiceCard `React.memo`, `useRef` 캐시 참조로 콜백 안정화, `useMemo`.
- 에러: `shouldRetry`(5xx retry 방지), `ErrorFallback`, `refetchOnWindowFocus: false`.
- 테스트: vitest + jsdom + coverage v8, 40건 통과, 커버리지 Stmts 96% / Branch 91.8% / Funcs 93.75% / Lines 100%. `npm run build` 통과(350 kB JS, 79 kB CSS), Vercel 배포. 26개 커밋, 43개 파일(+5,455 / -632).
- 2026-04-22 보고: 홈/문제목록/문제풀기/데일리챌린지/통계/설정 전 화면 연동 완료, JWT 인증 기반 API 클라이언트 전환(GitHub #121)까지 완료.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 참고사항: 신규 회원(submit 이력 없음) 호출 시 `/api/progress`, `/api/meta/topics`, `/api/questions` 백엔드 500 — 빈 결과 반환 처리가 백엔드에서 필요. 유사 문제 추천 UI 미연결, today·recent-wrong은 백엔드 구현 후 연동.

## 교훈
원본에 적혀 있지 않다.
