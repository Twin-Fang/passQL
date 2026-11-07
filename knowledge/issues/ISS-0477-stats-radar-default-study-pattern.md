---
type: issue
id: ISS-0477
created: 2026-11-07
topics: [progress-stats, design-system]
symptoms: ["영역별 정답률 목록 기본", "육각형 그래프 토글 눌러야 보임", "레이더 차트 토글", "학습 통계 적음", topic_accuracy_section.dart, Stats.tsx]
root_cause: "기능 개선: 영역별 정답률이 목록 기본 + 같은 자리 차트 토글(DEC-0206)이었고, 이미 있는 학습 데이터로 보여 줄 통계 구간이 없었다"
status: resolved
resolution: "[[ISS-0477-stats-radar-default-study-pattern-report]]"
related: ["[[DEC-0274-stats-radar-above-list-study-pattern-free]]", "[[DEC-0206-topic-accuracy-list-with-octagon-chart]]", "[[DEC-0043-topic-correct-rate-last-7-days]]", "[[DEC-0004-free-pro-feature-boundary]]"]
source: "https://github.com/Twin-Fang/passQL/issues/909"
---

# ISS-0477: 통계 화면 개편: 육각형 그래프 기본, 차트와 학습 통계 추가

GitHub #909 (https://github.com/Twin-Fang/passQL/issues/909). 직전 구조는 [[DEC-0206-topic-accuracy-list-with-octagon-chart]]. 원본 사본: `_sources/issues/ISS-0477-stats-radar-default-study-pattern.md`(로컬).

## 증상
- 영역별 정답률이 목록 기본, 육각형(레이더) 그래프는 오른쪽 위 토글을 눌러야 보임.
- 목록과 그래프를 토글로 바꾸는 방식이 맞는지 다시 봐야 함.
- 보여 줄 수 있는 학습 통계가 더 있는데 화면에 적음 (후보: 날짜별 학습, 요일과 시간대, 과목별 예상 점수, 난이도별 정답률, 오답 줄어드는 추이, 모의고사 회차별 점수).

## 재현 조건
앱 프로필 통계, 웹 통계 화면.

## 조사 기록
- 2026-11-07: 서버 5b2d0836, 앱 a67b3266, 웹 1d4b4e52. PR #915 머지.

## 근본 원인
해당 없음 (기능 개선). 이전 결정 [[DEC-0206-topic-accuracy-list-with-octagon-chart]]이 목록 기본 + 토글을 정했다.
