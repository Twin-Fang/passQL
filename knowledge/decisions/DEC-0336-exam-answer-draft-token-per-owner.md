---
type: decision
id: DEC-0336
created: 2026-11-16
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]", "[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[DEC-0320-exam-answer-disputed-shows-operator-candidate]]"]
---

# DEC-0336: 가채점 OMR 임시 답안과 답안지 토큰은 주인별(로그인 `member_{회원 uuid}`, 비로그인 `guest`)로 기기에 저장하고, 주인 구분 전 기기 공용 키는 이관하지 않고 읽지 않는다

## 문제 정의 (Context)
#1075 구현([[ISS-0520-sqld-round-answer-key-omr-grading]])은 로그인 여부와 무관하게 기기당 토큰 하나·회차별 임시 답안 하나를 썼다. 그래서 로그아웃 후 다른 계정으로 로그인해도 이전 계정의 답이 보였다 (GitHub #1136, [[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]).

## 결정 (Decision)
- 주인 키: 로그인 `member_{회원 uuid}`, 비로그인 `guest`.
- 토큰 키 `exam_answer_client_token_{주인}`(보안 저장소), 임시 답안 키 `exam_answer_owner_draft_{주인}_{시험}_{회차}`(일반 저장소). 같은 주인의 재제출은 같은 답안지를 갱신.
- 옛 공용 키(`exam_answer_client_token`, `exam_answer_draft_`)는 누구 답인지 알 수 없어 이관하지 않고 읽지 않는다 (이슈 예상 동작 "기존 기기 키 답은 이관하지 않음").
- 앱 가채점 상태는 현재 회원 uuid 를 구독해 계정이 바뀌면 다시 불러오고, 불러오는 사이 계정이 바뀌면 그 결과를 버린다.

## 검토한 대안 (Alternatives)
- 옛 기기 키 답을 로그인 계정으로 이관: 이슈 본문이 이관하지 않기로 정함. 그 밖의 대안 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 계정을 바꿔도 다른 계정 답이 보이지 않는다. 서버 API·저장 형식(토큰 SHA-256)은 그대로.

**부정**
- 업데이트 직후 기존 사용자의 작성 중 임시 답안이 보이지 않고, 이미 제출한 답안지도 새 토큰으로는 조회되지 않는다(서버 집계에는 남음).
- 같은 기기의 비로그인 사용자끼리는 여전히 `guest` 하나를 공유한다.

## 영향 범위 (Scope)
앱 `core/exam_answer/exam_answer_device_store.dart`, `core/storage/storage_keys.dart`, `data/exam_answer/exam_answer_repository.dart`, `presentation/providers/exam_answer_providers.dart`, `exam_answer_device_store_test.dart`. 서버·소개 사이트 변경 없음.

## 출처 (References)
- GitHub #1136 이슈 본문 2번·「예상 동작」, PR #1137 커밋 cf096426 메시지, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1136#issuecomment-6909470371
- W4: [[DEC-0320-exam-answer-disputed-shows-operator-candidate]](가답안 출처·표시 정답·확정 채점, DEC-0316 대체)은 답안 저장 주인과 무관 — 충돌 없음. 기기 토큰 하나 방식은 볼트 결정이 아니라 #1075 코드 주석이었다.
