---
type: completion-report
id: ISS-0060
created: 2026-04-11
topics: [practice, home]
status: resolved
resolves: "[[ISS-0060-daily-challenge-result-ux]]"
related: ["[[DEC-0048-daily-challenge-wrong-answer-not-submitted]]"]
source: "https://github.com/Twin-Fang/passQL/issues/106"
---

# ISS-0060 완료 리포트: 키 라벨 제거, 데일리 챌린지 버튼 분기, 리다이렉트 버그 수정

GitHub #106 프론트 작업 댓글(2026-04-11) 기준.

## 해결 방법
- `AnswerFeedback.tsx`: 비교 블록에서 `choiceKey` prop 제거, "정답 SQL"/"내가 선택한 SQL" 라벨을 시맨틱 컬러로. `FeedbackState.isDailyChallenge` — 데일리 정답 "홈으로 가기"(`/`), 오답 "다시 풀기"(`/daily-challenge`), 일반 "문제 목록으로"(`/questions`).
- `Home.tsx`: `alreadySolvedToday`면 성공 카드 스타일·클릭 불가, 미완료는 `/daily-challenge`로.
- `DailyChallenge.tsx`: 오답이면 `submitAnswer`를 호출하지 않고 로컬 `SubmitResult`로 피드백만 표시. `invalidateQueries`의 `await` 제거, 리다이렉트 조건에 `!feedback` 추가.
- 수동 검증: 정답·오답 흐름, 완료 카드, 라벨 미표시.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
작업 댓글: 오답 시 서버 제출 기록이 남지 않는 것은 의도된 동작(오답은 완료로 처리하지 않음). 일반 문제 풀이는 `isDailyChallenge`가 undefined라 기존 동작 유지. 이슈 본문 3번(제출 버튼 스타일)은 GitHub #112에서 `btn-primary`로 통일했다.

## 교훈
(원본에 없음, 볼트 정리) 제출 직후 화면이 피드백 없이 다른 곳으로 튀면 쿼리 무효화를 `await`해 리다이렉트 조건이 먼저 참이 됐는지 본다.
