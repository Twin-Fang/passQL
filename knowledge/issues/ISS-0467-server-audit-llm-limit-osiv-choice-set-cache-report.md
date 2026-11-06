---
type: completion-report
id: ISS-0467
created: 2026-11-07
topics: [ops-infra, security, practice, ai, admin]
status: resolved
resolves: "[[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache]]"
related: ["[[DEC-0268-server-osiv-off]]", "[[DEC-0042-ai-comment-cache-evict-on-submit]]", "[[DEC-0102-fixed-error-messages-detail-in-logs]]", "[[DEC-0224-attach-to-existing-common-points]]"]
source: "_sources/issues/ISS-0467-server-audit-llm-limit-osiv-choice-set-cache-report.md"
---

# ISS-0467 완료 리포트: AI 코멘트 소유 확인·요청 제한, OSIV 끔, 내린 보기 묶음 거부, 설정 캐시 커밋 뒤 쓰기, 고정 오류 문구

GitHub #879 리포트 기준 (2026-11-07). PR #892 머지, 릴리스 #896 으로 운영 배포.

## 해결 방법
- 비용·자원 보호:
  - AI 코멘트: 세션이 없거나 다른 회원 것이면 LLM 없이 고정 응답, `MemberApiRateLimitRule` 에 AI 코멘트 추가.
  - OSIV 끔(`application.yml`) — [[DEC-0268-server-osiv-off]]. LLM·샌드박스 호출 동안 커넥션을 쥐지 않아 #497 분리가 실제로 효과를 냄.
  - 무료 제출은 실행 결과를 받지 않으므로 샌드박스 실행 생략.
  - 재색인(`QuestionVectorIndexService`)의 트랜잭션 제거.
- 판정·정합:
  - DISABLED·REPORTED 보기 묶음과 비활성 문제는 열기·채점 모두 거부, 새 에러 코드 `CHOICE_SET_UNAVAILABLE` (`QuestionService`, `SubmissionService`, `ChoiceSetResolver`).
  - 설정 캐시는 커밋 뒤 쓰고 TTL 을 둠 (`AppSettingCache`).
  - 개념 진행 저장에 행 잠금.
  - 요청 제한 IP 는 X-Forwarded-For 오른쪽(프록시가 붙인) 값 기준.
- 응답 품질: 예외 원문 대신 고정 문구(`GlobalExceptionHandler`), `Map` 본문 > 요청 DTO + 검증(필드 누락 500 > 400 `VALIDATION_ERROR`).
- 관리자·정리: 선택지 정책 목록에 `CURATED_ONLY`·`RESULT_MATCH` 추가, 정책 목록·설정 카테고리는 단일 원본에서 읽음(#875 후속). `ZoneId.of("Asia/Seoul")` 14곳 > `ServiceTimeZone`, UUID 파싱 5곳 > `UuidUtils`(스케줄러·모의고사 시간대 포함). 죽은 코드 제거, server/CLAUDE.md 정정. API 계약 갱신과 웹 타입 재생성.

## 검증
- 서버 `./gradlew build`, CI 통과.
- 운영 실측: 필수값 빠진 `POST /api/auth/reissue` > 400 `VALIDATION_ERROR` 한국어 문구(500·예외 원문 없음), 인증 없는 AI 코멘트 요청 > 401.

## 근본 원인 (확정)
OSIV 기본값이 켜진 채라 트랜잭션 분리가 무력했고, AI 코멘트 세션 소유·보기 묶음 상태·설정 캐시 커밋 시점·요청 본문 검증 확인이 빠져 있었다.

## 재발 방지
- OSIV 를 끈 상태가 전제 — 컨트롤러·응답 변환에서 지연 로딩 연관을 건드리지 않고 응답 DTO 는 서비스 안에서 만든다 (`LazyInitializationException`).
- 설정 캐시는 커밋 뒤 쓰므로, 같은 트랜잭션에서 설정을 바꾸고 바로 캐시를 읽으면 커밋 전에는 옛 값이 보인다.
- 시간대는 `ServiceTimeZone` 에서만 정한다. `ZoneId.of(...)` 를 새로 쓰지 않는다.

## 볼트 메모
- 예외 원문 제거는 [[DEC-0102-fixed-error-messages-detail-in-logs]](고정 문구만, 상세는 로그) 기준에서 어긋난 곳을 바로잡은 것이고, `UuidUtils` 공통화는 [[DEC-0224-attach-to-existing-common-points]] 를 따른다 — 새 결정 아님.
- 지운 죽은 코드 중 `AiCommentService.evictCache` 는 [[DEC-0042-ai-comment-cache-evict-on-submit]](제출 시 직접 evict)가 적은 무효화 메서드다. 호출처가 이미 없던 것으로 보이며, DEC-0042 의 무효화 방식이 현재와 맞는지는 원본에 기록 없음 — 확인 필요.

## 교훈
서비스 계층에서 트랜잭션을 나눠도 OSIV 가 켜져 있으면 요청 전체가 커넥션을 쥔다. 외부 호출을 트랜잭션 밖으로 뺄 때는 프레임워크 기본값(OSIV)까지 함께 확인한다.
