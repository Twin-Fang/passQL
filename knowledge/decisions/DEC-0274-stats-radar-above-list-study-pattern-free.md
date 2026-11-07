---
type: decision
id: DEC-0274
created: 2026-11-07
reviewed: null
topics: [progress-stats, design-system, billing]
status: active
supersedes: DEC-0206
superseded_by: null
related: ["[[ISS-0477-stats-radar-default-study-pattern]]", "[[ISS-0477-stats-radar-default-study-pattern-report]]", "[[DEC-0206-topic-accuracy-list-with-octagon-chart]]", "[[DEC-0043-topic-correct-rate-last-7-days]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0204-profile-drops-info-shown-elsewhere]]"]
---

# DEC-0274: 영역별 정답률은 레이더 그래프를 위에 기본으로, 목록을 바로 아래에 함께 두고(토글 없음), 학습 패턴 통계는 무료, 정답률 상세는 프로로 더한다

## 문제 정의 (Context)
[[DEC-0206-topic-accuracy-list-with-octagon-chart]]는 영역별 정답률을 목록 기본으로 두고 같은 자리에서 차트로 바꿔 보게 했다. 그래프는 오른쪽 위 토글을 눌러야 보였고, 이미 있는 학습 데이터로 보여 줄 통계가 화면에 적었다 (GitHub #909, [[ISS-0477-stats-radar-default-study-pattern]]).

## 결정 (Decision)
- **영역별 정답률:** 토글을 없애고 레이더 그래프(8각, 이슈에서는 "육각형 그래프")를 위에 기본으로, 숫자 목록을 바로 아래에 함께 둔다. 정렬 토글(정답률 낮은 순, 많이 푼 순)은 목록에만 걸리므로 목록 바로 위에 두고, 차트 꼭짓점 순서는 토픽 순서로 고정한다. 판정 기간 최근 7일을 표기한다([[DEC-0043-topic-correct-rate-last-7-days]]).
- **DEC-0206에서 그대로인 것:** 목록 줄 구성(토픽 타일, 영역 이름, 푼 수, 정답률, 누르면 그 영역 문제), 처음 4줄 + 펼치기, 약한 영역만 빨강, 차트는 영역 3개 이상일 때만, 차트를 라이브러리 없이 직접 그림.
- **학습 패턴(무료):** 최근 4주 학습(날짜별 맞힘과 틀림, 공부한 날, 최장 연속), 공부하는 시간(요일, 시간대, 가장 많이 푼 칸). API `GET /progress/study-pattern`.
- **정답률 상세(프로, `TOPIC_ANALYSIS`):** 난이도별 정답률(문제별 마지막 시도), 오답 정리(다시 맞힌 수, 주별 남은 오답). API `GET /progress/accuracy-detail`. 무료는 잠금 미리보기 한 칸.
- **모의고사 점수 추이:** 앱, 프로, 기록이 있을 때만.
- **판정은 서버:** 앞뒤 2주 비교 조건, 가장 많은 요일과 시간(10문제 미만이면 판정 없음)은 서버 계산기(`StudyPatternCalculator`, `AccuracyDetailCalculator`)가 하고 앱과 웹은 보여 주기만 한다.
- **차트 구현:** 앱은 차트 라이브러리 없이 디자인 시스템 `PassqlBarChart`(토큰 색, 동작 줄이기, 스크린리더 한 문장), 웹은 이미 쓰던 recharts.

## 검토한 대안 (Alternatives)
- 목록과 그래프 토글 유지: 이슈 본문이 "토글 대신 위아래 배치를 우선 검토"라고 적었고, 리포트는 위아래 배치로 "모양과 정확한 숫자를 한 번에" 본다고 적었다. 그 밖의 논의 기록 없음.
- 차트 후보 6개 중 "과목별 예상 점수와 합격선 막대"는 이번 구간에 넣지 않았다. 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 그래프와 숫자를 한 화면에서 함께 보고, 무료 회원도 학습 패턴 통계를 본다.

**부정 / 조건**
- 웹 통계에는 모의고사 점수 추이가 없고(앱만), 모의고사 화면 막대 차트는 옛 구현으로 남았다 (리포트 「남은 일」).
- 판정 기준을 앱이나 웹에서 다시 계산하면 기준이 갈라진다 (리포트 「주의할 점」).

## 영향 범위 (Scope)
서버 `StudyStatsService`, `StudyStatsQueryRepository`, 계산기 3개, `ProgressController`, API 계약. 앱 `topic_accuracy_section.dart`, 새 통계 구간 위젯 5개, `passql_bar_chart.dart`, `stats_providers.dart`. 웹 `Stats.tsx`, `components/stats/*`, `useStudyStats.ts`.

## 출처 (References)
- GitHub #909 이슈 본문, 구현 확인 댓글, 리포트 댓글 (2026-11-07), PR #915
- 대체 대상: [[DEC-0206-topic-accuracy-list-with-octagon-chart]]
- W4 충돌 검사: [[DEC-0004-free-pro-feature-boundary]](통계는 무료 기본 수치, 프로는 토픽별 약점)와 충돌 없음. [[DEC-0043-topic-correct-rate-last-7-days]]와 같은 7일 기준. [[DEC-0204-profile-drops-info-shown-elsewhere]]의 프로필 위계(내 상태 > AI 분석 > 영역별 정답률 > 광고)에 새 구간이 더해졌으나 배치 순서를 바꾸는지는 원본에 기록 없음.
