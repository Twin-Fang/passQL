---
type: completion-report
id: ISS-0077
created: 2026-04-11
topics: [home, practice]
status: resolved
resolves: "[[ISS-0077-home-today-recommend-stale-after-submit]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/134"
---

# ISS-0077 완료 리포트: 제출 성공 시 `invalidateQueries` 추가

GitHub #134 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `client/src/pages/DailyChallenge.tsx`: 정답 제출 성공 후 `recommendations` 무효화 추가, `useCallback` 의존성에 `queryClient`·`uuid` 추가.
- `client/src/pages/QuestionDetail.tsx`: 제출 성공 시 `recommendations` 무효화, `handleSubmit` 의존성에 `queryClient`.
- `invalidateQueries`는 `await` 없이 호출해 네비게이션을 즉시 진행하는 기존 패턴 유지.

## 근본 원인 (확정)
`staleTime` 5분 동안 캐시를 그대로 반환했고 제출 경로에 무효화가 빠져 있었다.

## 재발 방지
리포트 주의사항: `useProgress`는 이미 `staleTime: 0`이라 무효화 불필요. `DailyChallenge` 오답 경로는 서버에 제출하지 않으므로 무효화 대상이 아니다.

## 교훈
(원본에 없음, 볼트 정리) 제출 후 다른 화면 데이터가 안 바뀌면 그 화면 쿼리의 `staleTime`과 제출 경로의 무효화 목록을 함께 본다.
