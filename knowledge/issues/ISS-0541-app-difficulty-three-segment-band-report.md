---
type: completion-report
id: ISS-0541
created: 2026-11-17
topics: [design-system, practice, progress-stats, home]
status: resolved
resolves: "[[ISS-0541-app-difficulty-three-segment-band]]"
related: ["[[DEC-0343-app-difficulty-three-segment-band-with-label]]", "[[DEC-0342-app-difficulty-text-label-three-levels]]"]
source: "_sources/issues/ISS-0541-app-difficulty-three-segment-band-report.md"
---

# ISS-0541 완료 리포트: 난이도 가로 3칸 띠 공통 부품, 홈 추천 회색 메타 한 줄 (#1147)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1147#issuecomment-6935247558 · PR #1148 (main 머지, 앱 배포 전)

## 해결 방법
- **공통 부품:** `PassqlDifficultyIndicator` — 띠 3칸(토큰 `difficultySegmentWidth` 10, `difficultySegmentHeight` 4, 간격 `hairlineGap` 2, 채운 칸 secondaryLabel, 빈 칸 tertiaryLabel) + 글자, 메타 줄용 `spanOf`(가운데 정렬 `WidgetSpan`). 스크린리더는 "난이도 보통".
- **단계 원본:** `QuestionDifficultyLevel.difficultyStepNumber`(1~3), `difficultyStepCount`(3). 1~5 > 단계는 #1145 의 `toQuestionDifficultyLevel` 재사용.
- **화면:** 풀이 머리 `━━─ 보통 | 개념 문제 | 최신 경향`, 홈 추천 `SQL 기본 | 최신 경향 | ━━─ 어려움`(제목 아래 난이도 줄 제거), 프로필 정답률 라벨 앞 띠(라벨 칸 56 > 88, 큰 글자는 줄임).
- **정리:** `PassqlLatestTrendBadge`, 배지 종류 `latestTrend` 제거(홈 추천이 유일한 사용처).

## 근본 원인 (확정)
디자인 개선 요청 — 글자만으로는 단계의 시각적 구분이 없었다.

## 재발 방지
- 디자인 시스템 규칙 테스트: 화면 코드의 `toDifficultyLabel(`, `.difficultyStepNumber/Count` 직접 사용 금지(금지 패턴 14종).
- 단계 경계값 테스트(2 > 1칸, 3 > 2칸, 4 > 3칸). `flutter analyze` 0, `flutter test` 전체 통과, 라이트·다크 테스트 렌더 캡처 확인.
- 주의 사항(보고서): `spanOf` 의 글자 배율 끄기를 빼면 큰 글자에서 띠 옆 글자만 두 번 커진다. getter 이름을 바꾸면 규칙 정규식도 함께 바꾼다. 모의고사 회차 평균 난이도는 범위 밖이라 글자만.

## 교훈
- 규칙 테스트 정규식에 쓸 이름은 다른 코드와 겹치지 않게 고유하게 짓는다(`stepNumber` 가 다른 위젯 필드를 오탐).
