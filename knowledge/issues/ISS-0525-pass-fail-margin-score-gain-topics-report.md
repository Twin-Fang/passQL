---
type: completion-report
id: ISS-0525
created: 2026-11-16
topics: [progress-stats, practice]
status: resolved
resolves: "[[ISS-0525-pass-fail-margin-score-gain-topics]]"
related: ["[[DEC-0322-score-gain-topics-exam-weighted]]", "[[DEC-0323-pass-fail-margin-count-single-source]]", "[[DEC-0260-exam-forecast-score-thresholds]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1111#issuecomment-6898335129"
---

# ISS-0525 완료 리포트: 과락·합격선 여유를 문항 수로, 점수 올리기 좋은 영역 상위 3개를 기대 상승 점수로

PR #1114 머지 · 릴리스 PR #1115

## 해결 방법
- **여유 문항 수** — [[DEC-0323-pass-fail-margin-count-single-source]]: 서버 `SqldScoreMargin`(PQL-Domain-Submission)이 `MockExamRule` 기준으로 과목 여유(정답 수 − 1과목 4 / 2과목 16)와 합격선 여유(정답 수 − 30)·문구를 계산. 모의고사 결과에 `passMarginText`(무료 포함)·`subjects[].failMarginText`(프로), 예상 점수 설명은 "1과목 과락까지 여유 2문제, 합격선까지 3문제 더"(여유가 적은 과목 + 합격선 거리). `ExamForecastCalculator` 규칙 상수 사본은 원본 참조로 정리.
- **점수 올리기 좋은 영역** — [[DEC-0322-score-gain-topics-exam-weighted]]: `ScoreGainTopicCalculator`가 출제 문항 수 × (75% − 내 정답률) × 2점으로 계산, 5문제 이상·0.5점 이상만, 큰 순 3개를 `AiStatsAnalysis.scoreGainTopics`로. 앱은 예상 점수 아래 `PassqlListRow`(영역, `정답률 N% | 시험 N문항`, `+N점` ›, 누르면 챕터 풀이).
- API 계약(`openapi.json`)·웹 타입 갱신.

## 근본 원인 (확정)
여유 문항 수를 계산하는 지점이 없었고, 약점 추천이 정답률만 봐서 출제 비중이 빠졌다.

## 검증
- 서버 `./gradlew build` 성공(`SqldScoreMarginTest`, `ScoreGainTopicCalculatorTest` 신규, `ExamForecastCalculatorTest` 문구 갱신, `OpenApiContractTest`).
- 앱 `flutter analyze` 0, `flutter test` 188개 통과. 웹 `tsc -b --noEmit` 통과. 라이트·다크 전/후 캡처(PR #1114 본문).
- 릴리스 PR #1115: 서버·AI·웹·Android 배포 성공, iOS(TestFlight·심사 제출)는 2026-11-16 기준 진행 중(결과는 이슈 후속 댓글).

## 재발 방지
- SQLD 규칙 숫자는 `MockExamRule`에만. 여유 계산기·예상 점수 계산기에 다시 적지 않는다.
- 추천 기준 75%·5문제는 `AiAnalysisPlanner` 상수 참조라 판정 기준을 바꾸면 추천 순위도 바뀐다.
- `scoreGainTopics` 없는 예전 Redis 분석 캐시는 빈 목록으로 읽혀 구간이 숨는다. 앱이 서버보다 먼저 나가면 새 문구 필드가 비어 기존 문구로 보인다. 웹은 새 필드를 아직 표시하지 않는다.

## 교훈
"약점"을 추천할 때는 정답률만이 아니라 시험 출제 비중을 곱한 기대 점수로 순위를 매겨야 수험생이 원하는 "어디를 공부하면 점수가 오르나"에 답한다.
