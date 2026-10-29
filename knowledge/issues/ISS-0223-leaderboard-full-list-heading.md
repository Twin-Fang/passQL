---
type: issue
id: ISS-0223
created: 2026-10-07
topics: [progress-stats]
symptoms: ["오늘의 순위", "내 순위 중복처럼 보임", "같은 행이 두 번", "전체 순위 제목 없음"]
root_cause: "\"내 순위\" 아래 전체 목록에 제목이 없었다"
status: resolved
resolution: "[[ISS-0223-leaderboard-full-list-heading-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/378"
---

# ISS-0223: 오늘의 순위 전체 목록에 제목이 없어 내 순위와 중복처럼 보임 (앱)

GitHub #378 (원본: 이슈 본문과 완료 댓글). QA GitHub #357 영역 5 관찰 항목.

## 증상
"내 순위" 아래 전체 목록에 제목이 없어, 참가자가 나뿐일 때 같은 행이 두 번 나오는 것처럼 보인다.

## 재현 조건
참가자가 나 혼자인 날 오늘의 순위 화면.

## 조사 기록
- 2026-10-07: 작업 범위 — 전체 목록 위에 "전체 순위 · N명" 제목.

## 근본 원인
전체 목록 섹션에 제목이 없었다.
