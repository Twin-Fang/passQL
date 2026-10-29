---
type: issue
id: ISS-0031
created: 2026-04-09
topics: [progress-stats, home]
symptoms: ["학습 히트맵", "/progress/heatmap", "날짜별 학습 기록", "잔디 캘린더", "sparse array"]
root_cause: "`GET /progress`가 누적 통계만 반환해 날짜별 풀이 수를 알 수 없었다 (기능 요청)"
status: resolved
resolution: "[[ISS-0031-daily-study-heatmap-api-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/42"
---

# ISS-0031: 날짜별 학습 기록 히트맵 API

GitHub #42 (원본: 이슈 본문과 댓글).

## 증상
홈에 GitHub 잔디 스타일 학습 히트맵을 구현하려 했으나 날짜별 학습 기록 API가 없었다. `GET /progress`는 `solvedCount`, `correctRate`, `streakDays`만 반환했고 스트릭도 숫자뿐이라 캘린더로 시각화할 수 없었다.
요청: `GET /api/progress/heatmap?memberUuid=&from=&to=`(기본 30일 전 ~ 오늘) → `{ entries: [{ date, solvedCount, correctCount }] }`, 기록 없는 날짜는 제외(sparse array). 색상 5단계(Design.md 기준 `#F5F5F5` / `#EEF2FF` / `#C7D2FE` / `#818CF8` / `#4F46E5`).

## 재현 조건
해당 없음 (기능 요청).

## 조사 기록
- 2026-04-10: 백엔드 `## 개요` 리포트 댓글, `@suh-lab server build` 호출.
- 2026-04-10: 프론트 작업 보고 댓글, "완료했습니다" 댓글.

## 근본 원인
해당 없음 (기능 요청).
