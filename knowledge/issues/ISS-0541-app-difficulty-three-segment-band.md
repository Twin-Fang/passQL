---
type: issue
id: ISS-0541
created: 2026-11-17
topics: [design-system, practice, progress-stats, home]
symptoms: ["난이도 글자만으로 단계가 한눈에 안 들어옴", "난이도 가로 3칸 띠", "PassqlDifficultyIndicator", "difficultyStepNumber", "toDifficultyLabel", "홈 추천 보라 칩", "PassqlLatestTrendBadge", "WidgetSpan 글자 배율 이중 확대", "this.stepNumber 규칙 테스트 오탐"]
root_cause: "난이도를 회색 글자로만 보여 줘 단계가 시각적으로 구분되지 않았고, 홈 추천 행은 보라 칩이 회색 메타 줄과 모양이 달랐다(디자인 개선 요청)"
status: resolved
resolution: "[[ISS-0541-app-difficulty-three-segment-band-report]]"
related: ["[[DEC-0343-app-difficulty-three-segment-band-with-label]]", "[[DEC-0342-app-difficulty-text-label-three-levels]]"]
source: "_sources/issues/ISS-0541-app-difficulty-three-segment-band.md"
---

# ISS-0541: 앱 난이도 표시를 가로 3칸 띠와 글자로, 홈 추천 칩을 회색 메타 한 줄로

GitHub #1147 (열림, 작업중 — 앱 배포 대기). 원본: https://github.com/Twin-Fang/passQL/issues/1147 · PR #1148

## 증상
- #1145 이후 난이도가 회색 글자(쉬움, 보통, 어려움)로만 보여 단계가 한눈에 들어오지 않는다.
- 홈 추천 행은 보라 알약 칩(토픽, 최신 경향) + 제목 + 아래 난이도 줄이라 풀이 머리의 회색 메타 한 줄과 모양이 다르다.

## 재현 조건
앱 풀이 화면 머리, 홈 추천 문제 구간, 프로필 난이도별 정답률(프로).

## 조사 기록
- 2026-11-16: 난이도 표시 시안 v3에서 6가지 방식 비교, 사용자가 E. 가로 3칸 띠 선택(정답률 방식은 표본 부족) — [[DEC-0343-app-difficulty-three-segment-band-with-label]].
- 2026-11-17: 이슈 등록, 구현(PR #1148 main 머지). 공통 부품 `PassqlDifficultyIndicator`, 단계 `difficultyStepNumber`, 세 화면 적용, 칩 제거.
- 2026-11-17: 단계 getter 를 처음 `stepNumber` 로 지었더니 규칙 테스트 정규식이 홈 환영 안내의 `this.stepNumber` 를 잡았다 > `difficultyStepNumber` 로 고유하게 바꿈.
- 2026-11-17: 메타 줄 `WidgetSpan` 은 줄 글자 배율만큼 자식을 통째로 키워 안쪽 글자가 두 번 커질 수 있다 > `spanOf` 안쪽에서 `MediaQuery.withNoTextScaling`.

## 근본 원인
난이도를 글자로만 표시해 단계의 시각적 구분이 없었다(디자인 개선 요청, 결함 아님).
