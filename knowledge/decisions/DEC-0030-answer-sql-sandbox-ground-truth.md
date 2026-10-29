---
type: decision
id: DEC-0030
created: 2026-04-09
reviewed: null
topics: [question-bank, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0029-realtime-ai-choice-set-prefetch]]", "[[DEC-0028-realtime-choice-set-with-prefetch]]"]
---

# DEC-0030: `answer_sql` 샌드박스 실행 결과를 정답의 진실로, 정답 수가 1이 아니면 최대 3회 재생성 후 `FAILED`

## 문제 정의 (Context)
AI가 생성한 선택지 세트의 정답을 무엇으로 판정할지 정해야 했다 (GitHub #39).

## 결정 (Decision)
- `answer_sql` 실행 결과가 진실(ground truth)이다.
- 선택지 세트의 `correctCount != 1`이면 최대 3회 재생성한다.
- 3회 모두 실패하면 `status = FAILED`로 저장하고 사용자에게 재시도를 안내한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.
(원본 기록) 같은 이슈의 관리자 문제 등록 구현 계획 댓글은 "현재 구현은 Gemini가 `is_correct`를 반환하고 샌드박스 실행은 참고용 배지로만 표시. 실행 결과로 자동 override할지는 관리자가 결정"을 미결 사항으로 남겼고, 설계 댓글도 "EXECUTABLE 정답 판별 기준 확정 필요"를 미결로 적었다. 이 범위(관리자 등록 화면)에서의 최종 결론은 원본에 없다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 3회 실패 시 사용자는 그 문제의 선택지를 받지 못하고 재시도해야 한다.

## 영향 범위 (Scope)
선택지 세트 생성·검증 서비스, `SandboxExecutor`, `question.answer_sql`, `question_choice_set.status`.

## 출처 (References)
- GitHub #39 이슈 본문 「샌드박스 검증 기반 정답 판정」, 구현 계획 댓글 「미결 사항」, 설계 댓글 「미결 사항」
