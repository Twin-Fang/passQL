---
type: decision
id: DEC-0323
created: 2026-11-16
reviewed: null
topics: [practice, progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0525-pass-fail-margin-score-gain-topics]]", "[[ISS-0525-pass-fail-margin-score-gain-topics-report]]", "[[DEC-0260-exam-forecast-score-thresholds]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]"]
---

# DEC-0323: 과락·합격선 여유는 문항 수로 말하고, 서버 `SqldScoreMargin` 한 곳에서 `MockExamRule` 기준으로 계산해 모의고사 결과(합격선 문장 무료, 과목 여유 프로)와 예상 점수 설명에 함께 쓴다

## 문제 정의 (Context)
모의고사 결과와 예상 점수가 점수만 보여 주고 "몇 문제 더 틀리면 과락인지, 합격선까지 몇 문제인지"를 말하지 않았다. 예상 점수 계산기에는 SQLD 규칙 상수 사본이 원본과 따로 있었다 (GitHub #1111, [[ISS-0525-pass-fail-margin-score-gain-topics]]).

## 결정 (Decision)
- 여유는 점수가 아니라 **문항 수**로 말한다. 과목 여유 = 정답 수 − 과락 면하는 최소 정답(1과목 4, 2과목 16), 합격선 여유 = 정답 수 − 30. 0 이상이면 더 틀려도 되는 수, 음수면 더 맞혀야 할 수.
- 계산과 문구는 서버 `SqldScoreMargin` 한 곳, 기준은 `MockExamRule`(문항 2점, 과목 40% 미만 과락, 60점 합격) 원본. `ExamForecastCalculator`도 원본을 참조하고 상수 사본을 두지 않는다.
- 모의고사 결과: 합격선 문장 `passMarginText`는 무료 포함, 과목 칸 `failMarginText`는 기존 과목 분석 잠금(프로)을 그대로 따른다.
- 예상 점수 설명: 여유가 적은 과목(같으면 1과목)의 과락 여유 + 합격선 거리 한 줄(예: "1과목 과락까지 여유 2문제, 합격선까지 3문제 더"). 과락 위험이면 "1과목 과락을 넘으려면 1문제 더 맞혀야 해요".

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 1과목 과락 걱정을 숫자로 관리할 수 있다. SQLD 규칙이 서버에 한 벌만 남는다.

**부정**
- 앱이 서버보다 먼저 배포되면 새 문구 필드가 비어 기존 문구로 보인다(구버전 호환). 웹은 새 필드를 아직 표시하지 않는다.

## 영향 범위 (Scope)
서버 `SqldScoreMargin`, `MockExamResultAssembler`, `MockExamResultResponse`, `ExamForecastCalculator`, API 계약·웹 타입. 앱 `mock_exam_score_hero.dart`, `mock_exam_subject_breakdown.dart`, `mock_exam_result.dart`.

## 출처 (References)
- GitHub #1111 이슈 본문 「해결 방안」 1, PR #1114 본문, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1111#issuecomment-6898335129
- W4 충돌 검사: [[DEC-0260-exam-forecast-score-thresholds]](과락 40%·70/54점 판정 구간)은 그대로이고 설명 문구만 바뀜, [[DEC-0264-mock-exam-fixed-rounds-server-judged]](서버 판정)·[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]](과목별 기준 칸, 넘어야 할 점수 표기)과 같은 방향 — 충돌 없음. 합격선 문장 무료 공개는 [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]](상위 N% 무료)처럼 총점 수준 정보라 기존 무료/프로 경계 안.
