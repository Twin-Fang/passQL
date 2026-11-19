---
type: issue
id: ISS-0545
created: 2026-11-19
topics: [progress-stats, practice, design-system]
symptoms: ["모의고사 점수 추이 빈 차트", "점수 추이 붉은 덩어리", "낮은 점수 막대 타원", "MockExamTrendChart", "점수 추이 바닥선 없음", "틀린 문항 개념 복습 모름 포함", "틀린 문항 수가 너무 많음", "가채점 복습 44", "wrongMarks 모름"]
root_cause: "점수 추이 막대가 네 모서리 반경 8·바닥선 없음으로 그려져 낮은 점수가 덩어리로 보였고, 가채점 복습 목록은 모름(0점)을 일부러 포함하는데 머리글만 '틀린 문항'이었다"
status: resolved
resolution: "[[ISS-0545-mock-exam-trend-bar-blob-grading-review-unknown-label-report]]"
related: ["[[ISS-0477-stats-radar-default-study-pattern]]", "[[ISS-0542-past-exam-grading-omr-link]]", "[[ISS-0544-callout-no-left-bar-roadmap-home-entry]]", "[[DEC-0274-stats-radar-above-list-study-pattern-free]]", "[[DEC-0344-past-exam-grading-reuses-answer-key-round]]", "[[DEC-0347-roadmap-entry-home-only-more-practice-group]]", "[[DEC-0348-exam-grading-review-includes-unknown-answers]]"]
source: "_sources/issues/ISS-0545-mock-exam-trend-bar-blob-grading-review-unknown-label.md"
---

# ISS-0545: 모의고사 점수 추이 낮은 점수 막대 덩어리, 가채점 복습 문구에 모름 누락 (#1166)

GitHub: https://github.com/Twin-Fang/passQL/issues/1166

## 증상
- 프로필·모의고사 탭 「점수 추이」에서 점수 2개(14점, 2점)일 때 차트가 거의 비어 보인다. 14점은 붉은 덩어리, 2점은 가는 가로선이고 바닥선이 없어 막대가 떠 보인다.
- 가채점 결과 「틀린 문항 개념 복습 N」 수에 모름 문항이 섞인다(28문항 입력 시 44).

## 재현 조건
프로 계정 모의고사 낮은 점수 응시 2회 > 프로필. 지난 회차 가채점에서 일부 문항만 입력하고 채점(남은 문항은 모름).

## 조사 기록
- 2026-11-19: `MockExamTrendChart` 막대 `BorderRadius.circular(PassqlRadius.sm)`(8), 높이 = 116 x 점수/100 > 14점은 약 16px 알약 모양. 같은 화면 `PassqlBarChart` 는 바닥선 + 윗모서리 반경 최대 4 + 최소 높이 2.
- 2026-11-19: `ExamAnswerScoreReport.wrongMarks` = isCorrect false(모름 포함). 행 부제가 `내 답 모름`을 따로 표시해 포함은 의도, 머리글만 어긋남.
- 같은 실측에서 본 다른 2개는 결함 아님: 문제 탭 학습 가이드 2행은 #1158(DEC-0347)에서 이미 해결, 「이 회차 기출 풀기」 > 기출 복원 탭은 설계(DEC-0344) 그대로.

## 근본 원인
점수 추이 차트가 디자인 시스템 막대 차트와 별도로 구현돼 모양 규칙(반경·최소 높이·바닥선)을 따르지 않았다. 복습 머리글은 모름 포함을 반영하지 않은 문구였다.
