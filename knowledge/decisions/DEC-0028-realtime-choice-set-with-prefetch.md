---
type: decision
id: DEC-0028
created: 2026-04-09
reviewed: null
topics: [practice, ai, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0029-realtime-ai-choice-set-prefetch]]", "[[DEC-0030-answer-sql-sandbox-ground-truth]]", "[[ISS-0032-admin-direct-question-register]]"]
---

# DEC-0028: 문제는 고정, 선택지 세트는 퀴즈 진입마다 AI로 생성하고 다음 문제 세트는 프리페치 (MVP는 `AI_ONLY`)

## 문제 정의 (Context)
선택지가 문제에 고정되어 반복 풀이 시 정답 패턴이 외워졌고, 실시간 생성이라는 차별점을 살리지 못했다. 진입마다 AI를 부르면 지연이 커졌다 (GitHub #39).

## 결정 (Decision)
- 문제(`question`)는 고정, 선택지 세트(`question_choice_set`)는 퀴즈 진입 시마다 AI로 생성한다.
- N번 문제를 푸는 동안 N+1번 문제의 선택지 세트를 백그라운드에서 미리 생성한다.
- MVP 정책은 `AI_ONLY` 단일 모드. `CURATED_ONLY` / `HYBRID`는 enum·컬럼만 예약한다. `source` 다값 enum, `is_reusable` 플래그, `status = REPORTED`를 예약해 확장 분기점을 미리 둔다.
- `question`에 `choice_set_policy` 컬럼. `question_choice_set`은 `source`, `status`, `member_id`, `raw_response_json`, `consumed_at`, `is_reusable`을 가진다.

## 검토한 대안 (Alternatives)
- 선택지 고정(기존 구조): 정답 패턴 암기 문제로 대체.
- `CURATED_ONLY` / `HYBRID`: MVP에서는 동작시키지 않고 예약만. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 이슈 본문: 프리페치로 체감 지연 최소화, 향후 CURATED/HYBRID/신고 처리로 확장 경로 확보.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Flyway `V0_0_28`(question 재설계, `question_choice_set`, `question_choice_set_item`, `quiz_session`, `submission` 확장), 선택지 세트 생성 서비스, 퀴즈/제출 플로우. GitHub #46의 "선택지 없이 문제만 저장하고 AI가 이후에 선택지를 자동 생성"하는 직접 등록 경로와 이어진다.

## 출처 (References)
- GitHub #39 이슈 본문 「핵심 아키텍처」·「데이터 모델」·「확장성 확보」
