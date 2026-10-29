---
type: issue
id: ISS-0018
created: 2026-04-08
topics: [ops-infra]
symptoms: ["submission 테이블 누락", question.is_active, Flyway, "데일리 챌린지 폴백", "UUID PK"]
root_cause: "홈 화면 API가 의존하는 `submission` 테이블과 `question.is_active` 컬럼이 Flyway V1 스키마에 없었다"
status: resolved
resolution: "[[ISS-0018-submission-table-question-active-report]]"
related: ["[[DEC-0023-uuid-primary-keys-all-tables]]"]
source: "https://github.com/Twin-Fang/passQL/issues/22"
---

# ISS-0018: Entity 스키마 보강 — submission 테이블, question.is_active

GitHub #22 (원본: 이슈 본문과 댓글).

## 증상
홈 화면 백엔드 API(`/api/progress`, `/api/questions/today`)가 `submission` 테이블과 `question.is_active` 컬럼에 의존하지만 Flyway V1 스키마에 없었다. `question.is_active`가 없으면 데일리 챌린지 폴백(활성 문제 풀에서 결정적 선택)이 동작하지 않는다. 다른 D3 이슈의 전제라 가장 먼저 머지되어야 한다고 적었다.
제안: `submission`(`submission_uuid` CHAR(36) PK, `member_uuid`, `question_uuid`, `selected_choice_key`, `is_correct`, `submitted_at`) + 인덱스 3개(`idx_submission_member_uuid`, `idx_submission_member_submitted`, `idx_submission_member_question`), `question.is_active BOOLEAN NOT NULL DEFAULT TRUE` + `idx_question_active`. 모든 PK는 UUID.

## 재현 조건
해당 없음 (선행 스키마 이슈).

## 조사 기록
- 2026-04-08: "전체 스키마에 대해서 전면 수정 UUID로 id변경했습니다" 댓글.

## 근본 원인
초기 스키마에 해당 테이블·컬럼이 없었다 (이슈 본문). 왜 빠졌는지는 원본에 적혀 있지 않다.
