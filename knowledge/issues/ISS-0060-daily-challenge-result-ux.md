---
type: issue
id: ISS-0060
created: 2026-04-11
topics: [practice, home]
symptoms: ["정답 B 오표시", "A/B/C/D 라벨", "다음 문제 버튼", "오늘의 문제", alreadySolvedToday, invalidateQueries, "피드백 전 홈 리다이렉트", "답안 제출 버튼 불일치"]
root_cause: "결과 비교 블록이 선택지 키 배지를 실제 정답 키가 아닌 고정 값으로 렌더링했고, 데일리 챌린지 분기 없이 '다음 문제'로 이동했으며, invalidateQueries를 await해 피드백 표시 전에 리다이렉트됐다"
status: resolved
resolution: "[[ISS-0060-daily-challenge-result-ux-report]]"
related: ["[[DEC-0048-daily-challenge-wrong-answer-not-submitted]]", "[[ISS-0064-recommended-flow-ui-unify]]"]
source: "https://github.com/Twin-Fang/passQL/issues/106"
---

# ISS-0060: 오늘의 문제 풀이·결과 화면 UX — 정답 오표시, 부적절한 버튼, 완료 카드 미반영

GitHub #106 (원본: 이슈 본문과 댓글).

## 증상
1. 결과 화면이 A를 골라 정답인데도 `정답 B`를 표시한다. A/B/C/D 라벨 자체가 불필요하다.
2. 1문제 플로우인 오늘의 문제에서 결과 하단 버튼이 `다음 문제`다.
3. `답안 제출하기` 버튼 스타일이 앱 전반과 다르다.
4. 정답 확인 화면의 답안 가독성이 낮다.

## 재현 조건
홈 → 오늘의 문제 → 선택지 A 선택 → 제출 → 결과 화면.

## 조사 기록
- 2026-04-11: 작업 댓글 분석 — `SqlCompareBlock`/`TextCompareBlock`이 고정 키 배지를 렌더링, `isDailyChallenge` 분기 없이 `navigate("/questions")`, 홈 카드가 `alreadySolvedToday`를 반영하지 않음, `queryClient.invalidateQueries`를 `await`해 `alreadySolvedToday=true`가 즉시 반영되며 피드백 전에 홈으로 이동.

## 근본 원인
이슈 노트 frontmatter `root_cause`와 같다.
