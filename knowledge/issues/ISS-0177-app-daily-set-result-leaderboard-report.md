---
type: completion-report
id: ISS-0177
created: 2026-10-07
topics: [practice, progress-stats]
status: resolved
resolves: "[[ISS-0177-app-daily-set-result-leaderboard]]"
related: ["[[DEC-0089-shared-question-flow-for-solving]]"]
source: "https://github.com/Twin-Fang/passQL/issues/332"
---

# ISS-0177 완료 리포트: 오늘의 세트 카드·풀이·결과·리더보드, `QuestionFlow` 공통화

GitHub #332 구현 댓글(2026-10-02)과 2026-10-07 확인 댓글 기준.

## 해결 방법
- 홈 "오늘의 문제" 카드를 오늘의 세트 카드로 교체(풀 수 있음 / 완료(정답 수) / 준비 중).
- 풀이: 챕터 풀이 화면을 공통화해 재사용, 한 번의 풀이를 하나의 세션 UUID로 묶어 답안 제출에 함께 전송.
- 마지막 제출 후 정답 수와 세션을 `POST /daily-set/complete`로 등록하고 결과 화면 이동. 점수 등록 실패 시에도 풀이 결과는 보여 주고 순위 미반영 안내, 이미 완료(409)는 정상 처리.
- 결과 화면(점수, 문제별 정오답, 상위 3명과 내 순위), 리더보드 화면(날짜, 전체 순위, 내 기록 강조). 홈 완료 카드는 서버 기록으로 결과 표시.
- 구조: `QuestionFlow` 추가 — `TopicFlow`, `DailySetFlow`가 사용.
- 서버에서 사라진 `/questions/today` 호출과 오늘의 문제 카드 코드 제거(`today_question_card.dart`, `TodayQuestionResponse`는 삭제 승인 후 정리).
- 검증: 2026-10-02 테스트 111개(29개 추가). 2026-10-07 테스트 147개, 실계정 E2E·TestFlight/Play 비공개 테스트 확인. "리더보드 점수는 서버가 제출 기록으로 검증한다(GitHub #342)."

## 근본 원인 (확정)
앱이 제거된 `/questions/today`를 호출하고 있었고 데일리 세트 화면이 없었다.

## 재발 방지
리더보드 점수 조작 위험은 서버 검증(GitHub #342)으로 처리.

## 교훈
(원본에 없음, 볼트 정리) 클라이언트가 보낸 점수를 그대로 저장하는 API는 서버 제출 기록과 대조해야 한다.
