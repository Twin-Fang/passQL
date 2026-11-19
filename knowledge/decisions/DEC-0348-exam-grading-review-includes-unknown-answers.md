---
type: decision
id: DEC-0348
created: 2026-11-19
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0545-mock-exam-trend-bar-blob-grading-review-unknown-label]]", "[[DEC-0344-past-exam-grading-reuses-answer-key-round]]"]
---

# DEC-0348: 가채점 결과 개념 복습 목록은 모름 문항도 포함하고, 머리글은 「틀리거나 모르는 문항 개념 복습 N」으로 쓴다

GitHub #1166.

## 문제 정의 (Context)
가채점 결과의 복습 목록은 모름 문항(0점)도 담고 행 부제에 `내 답 모름`을 보여 주는데, 머리글은 「틀린 문항 개념 복습 N」이었다. 일부만 입력하면 남은 문항이 모두 모름이 되어 수가 크게 늘었고(28문항 입력 시 44), 머리글과 목록 내용이 어긋났다.

## 결정 (Decision)
- 복습 목록은 틀린 문항과 모름 문항을 함께 담는다. 갈림·미확정(정오를 모르는 문항)은 넣지 않는다.
- 머리글은 `틀리거나 모르는 문항 개념 복습 N`, 빈 상태 문구 「정해진 문항은 모두 맞혔어요」는 그대로 둔다.

## 검토한 대안 (Alternatives)
- 모름을 목록에서 빼기: 모르는 문항도 개념 복습 대상이고, 채점 버튼이 "남은 N문항은 모름"으로 미리 알리므로 채택하지 않음(구현 중 판단, 사용자 논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 머리글 수와 목록 내용이 맞는다.

**부정**
- 일부만 입력하면 목록이 길어진다(입력하지 않은 문항이 모두 들어감).

## 영향 범위 (Scope)
앱 `widgets/exam_answer/exam_answer_my_score_tab.dart`, `core/exam_answer/exam_answer_score_report.dart`(`wrongMarks`).

## 출처 (References)
- GitHub #1166 이슈 본문, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1166#issuecomment-6996753804

## W4 검사
- DEC-0344(지난 회차 가채점 구조): 복습 목록 범위를 정하지 않았음, 충돌 없음. DEC-0315(원문 비게시): 개념 한 줄만 보여 줌, 충돌 없음.
