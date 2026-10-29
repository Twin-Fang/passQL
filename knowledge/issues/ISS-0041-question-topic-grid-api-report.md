---
type: completion-report
id: ISS-0041
created: 2026-04-10
topics: [practice, question-bank]
status: resolved
resolves: "[[ISS-0041-question-topic-grid-api]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/68"
---

# ISS-0041 완료 리포트: Mock을 BE 9개 토픽 코드로 교체하고 카테고리 그리드 구현

GitHub #68 프론트 작업 댓글(2026-04-10) 기준.

## 해결 방법
- `src/api/mock-data.ts`: `MOCK_TOPICS`를 BE 시드 9개 토픽으로 교체. `MOCK_QUESTIONS`의 `topicCode`·`topicName` 동기화(`CONSTRAINT` → `sql_basic_select`), 필터링을 `q.topicCode === topic` 직접 비교로 단순화.
- `src/pages/Questions.tsx`: URL search param 기반 두 뷰 — `/questions`는 `useTopics()`로 그리드(`isActive` 필터, `sortOrder` 정렬, 2열/3열), `/questions?topic=sql_join`은 문제 목록(난이도 필터만, "토픽 전체" 복귀). `useState` → `useSearchParams()`.
- `src/hooks/useQuestions.ts`: `enabled` 옵션 추가 — 그리드 뷰에서 불필요한 `GET /questions` 호출 방지.
- `TopicTree`·`SubtopicItem` 타입은 이미 BE 필드를 포함해 변경 불필요.
- 검증: 테스트 98개 통과(`npm test -- --run`), `npm run build`.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
BE 응답의 `isActive: false` 토픽은 그리드에서 자동 제외된다.

## 교훈
(원본에 없음, 볼트 정리) Mock 데이터의 코드 체계는 BE 시드 코드와 같게 유지해야 실서버 전환 때 필터가 깨지지 않는다.
