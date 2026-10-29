---
type: issue
id: ISS-0103
created: 2026-04-12
topics: [practice]
symptoms: [fk_submission_session, "409 Conflict", DATA_INTEGRITY_VIOLATION, DataIntegrityViolationException, quiz_session, session_uuid, "답안 제출 실패", crypto.randomUUID]
root_cause: "submission.session_uuid에 quiz_session FK가 걸려 있는데 quiz_session을 채우는 로직이 없고 클라이언트가 임의 UUID를 보낸다"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/186"
---

# ISS-0103: 답안 제출 시 `fk_submission_session` FK 위반으로 409

GitHub #186 (원본: 이슈 본문. 완료 댓글 없음).

## 증상
단독 풀이 모드에서 "답안 제출하기" → HTTP 409.
```
ERROR: insert or update on table "submission" violates foreign key constraint "fk_submission_session"
org.springframework.dao.DataIntegrityViolationException: could not execute statement
```
클라이언트: `POST /questions/{questionUuid}/submit 409 (Conflict)`, `errorCode: 'DATA_INTEGRITY_VIOLATION'`.

## 재현 조건
1. 단독 풀이 모드(`/questions/{questionUuid}`) 진입 2. 선택지 생성 후 보기 선택 3. "답안 제출하기" → 409, 서버 로그에 FK 위반.

## 조사 기록
- 2026-04-12: 이슈 등록. FK 생성 위치 `V0_0_28__realtime_choice_set.sql`, 재생성 위치 `V0_0_70__convert_uuid_char_to_native.sql`. 클라이언트 sessionUuid 생성 위치 `client/src/hooks/useQuestionDetail.ts`. 기대 동작: `session_uuid`는 AI 코멘트 세션 집계용 느슨한 식별자로 `quiz_session` 레코드와 무관하게 저장.
- 수정 방식·완료 기록은 원본에 적혀 있지 않다(이슈는 completed로 닫힘).

## 근본 원인
이슈 본문 기준: `quiz_session`을 채우는 세션 생성 로직이 없어 어떤 sessionUuid를 보내도 FK 위반이 나는 구조. 클라이언트는 `crypto.randomUUID()`로 임의 UUID를 보낸다.
