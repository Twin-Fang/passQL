---
type: completion-report
id: ISS-0545
created: 2026-11-19
topics: [progress-stats, practice, design-system]
status: resolved
resolves: "[[ISS-0545-mock-exam-trend-bar-blob-grading-review-unknown-label]]"
related: ["[[DEC-0348-exam-grading-review-includes-unknown-answers]]", "[[DEC-0274-stats-radar-above-list-study-pattern-free]]"]
source: "_sources/issues/ISS-0545-mock-exam-trend-bar-blob-grading-review-unknown-label-report.md"
---

# ISS-0545 완료 리포트: 점수 추이 막대 모양을 PassqlBarChart 규칙에 맞추고, 가채점 복습 머리글을 「틀리거나 모르는 문항」으로 (#1166)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1166#issuecomment-6996753804 · PR #1167 (main 머지, 배포 전)

## 해결 방법
- `MockExamTrendChart`: 바닥선, 윗모서리만 반경 4, 0이 아닌 점수 최소 높이 2 (`_barHeightOf`). 상수는 `PassqlBarChart.maximumTopRadius`·`minimumVisibleHeight` 를 공개해 참조한다. 0~100 눈금·합격선은 유지한다(합격선 위치를 보여 주려면 만점 기준이 필요해서 `PassqlBarChart` 의 최댓값 기준 높이를 쓰지 않음).
- 가채점 복습 머리글 `틀리거나 모르는 문항 개념 복습 N` — [[DEC-0348-exam-grading-review-includes-unknown-answers]].

## 근본 원인 (확정)
조사 기록과 같음.

## 재발 방지
- 차트 모양 상수의 원본을 `PassqlBarChart` 한 곳으로 모았다. `flutter analyze` 0건, `flutter test` 198개 통과, 테스트 렌더 라이트·다크 캡처.

## 남은 일
- 「이 회차 기출 풀기」를 해당 회차 시험 안내로 바로 보낼지 사용자 결정 필요(지금은 기출 복원 탭, 무료 최근 1회 경계 DEC-0328 과 함께 다뤄야 함).
- 기기 실측·배포는 사용자 확인 뒤.

## 교훈
디자인 시스템 컴포넌트를 그대로 못 쓰는 차트도 모양 상수는 원본을 참조해야 한 화면 안의 차트끼리 어긋나지 않는다.
