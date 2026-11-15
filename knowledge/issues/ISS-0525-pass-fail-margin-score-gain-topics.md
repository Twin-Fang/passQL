---
type: issue
id: ISS-0525
created: 2026-11-16
topics: [progress-stats, practice]
symptoms: ["과락까지 몇 문제", "합격선까지 몇 문제", "과락선 여유 문항", "예상 점수 설명", "어느 영역 공부", "점수 올리기 좋은 영역", "+N점", "출제 비중 미반영", "약점 토픽 정답률만", "SqldScoreMargin", "ScoreGainTopicCalculator", "ExamForecastCalculator 규칙 상수 사본", "scoreGainTopics", "passMarginText", "failMarginText"]
root_cause: "모의고사 결과·예상 점수가 점수만 주고 과락·합격선까지의 문항 수를 계산하지 않았고, 약점 추천이 정답률만 봐서 시험 출제 비중을 반영하지 못했다"
status: resolved
resolution: "[[ISS-0525-pass-fail-margin-score-gain-topics-report]]"
related: ["[[DEC-0322-score-gain-topics-exam-weighted]]", "[[DEC-0323-pass-fail-margin-count-single-source]]", "[[DEC-0260-exam-forecast-score-thresholds]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0258-ai-comment-pro-only-all-forms]]"]
source: "_sources/issues/ISS-0525-pass-fail-margin-score-gain-topics.md"
---

# ISS-0525: 과락선 여유 문항 안내, 점수 올리기 좋은 영역 +N점

GitHub #1111 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1111 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1111#issuecomment-6898335129 · PR #1114 (머지) · 릴리스 PR #1115

## 증상
- 모의고사 결과와 통계 AI 분석(예상 점수)에 과목 점수는 나오지만 "몇 문제 더 틀리면 과락인지", "합격선까지 몇 문제 더 맞혀야 하는지"를 문항 수로 말해 주지 않았다. 비전공자의 가장 큰 걱정인 1과목 과락을 숫자로 관리하기 어려웠다.
- 예상 점수를 봐도 어느 영역을 공부해야 점수가 가장 많이 오르는지 알 수 없었다. 약점 토픽은 정답률 기준이라 출제 비중(1과목 10문항, 조인 5문항 등)이 반영되지 않았다.

## 재현 조건
모의고사 결과 화면, 프로필 통계 AI 분석 예상 점수 구간.

## 조사 기록
- 2026-11-16: 수험생 공유 학습 사이트 조사(로컬 스펙 문서, 아이디어 2·3)에서 과락선 문항 수 안내와 영역별 기대 상승 점수가 유용한 기능으로 확인.
- 같은 조사의 "전체 사용자 오답률 TOP N"은 다른 세션 #1080(PR #1108)에서 이미 구현돼 범위에서 제외.
- 예상 점수 계산기(`ExamForecastCalculator`)에 SQLD 규칙 상수(10·40문항, 2점, 60점, 40%) 사본이 원본 `MockExamRule`과 별도로 있음을 확인.

## 근본 원인
여유 문항 수를 계산하는 지점이 없었고, 추천 기준에 출제 문항 수가 들어가지 않았다.
