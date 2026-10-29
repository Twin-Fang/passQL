---
type: issue
id: ISS-0050
created: 2026-04-11
topics: [practice, ops-infra]
symptoms: ["선택지 생성 중... 멈춤", "SSE complete 미전달", "두 번째 문제부터", HikariPool, "Pool-3", self-invocation, "@Transactional", "[choice-gen] success"]
root_cause: "ChoiceSetGenerationService가 같은 클래스의 @Transactional save 메서드를 self-invocation해 트랜잭션이 열리지 않았고, 커넥션 풀이 고갈돼 SSE 스레드가 블로킹됐다"
status: resolved
resolution: "[[ISS-0050-sse-complete-hikaripool-self-invocation-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/91"
---

# ISS-0050: 선택지 생성은 성공하는데 두 번째 문제부터 SSE `complete`가 오지 않아 화면 멈춤

GitHub #91 (원본: 이슈 본문과 댓글).

## 증상
두 번째 이후 문제에서 서버 로그에 `[choice-gen] success`가 찍히는데 클라이언트는 "선택지 생성 중..."에서 멈춘다. 첫 번째 문제는 정상. 서버 로그에서 HikariPool이 Pool-3, 4, 5, 6...으로 계속 생성·즉시 종료된다.

## 재현 조건
로컬(localhost:5174)에서 첫 문제 풀이·제출 후 다음 문제로 이동해 선택지 생성.

## 조사 기록
- 2026-04-11: 이슈 본문이 `saveSuccess()`, `saveFailed()`, `saveConceptSuccess()`의 `protected` + `@Transactional` self-invocation과 `ChoiceSetResolver.resolveForUser()`의 `@Transactional`(AI·샌드박스 호출 동안 트랜잭션 유지)을 지목.
- 2026-04-11: 리포트 댓글로 수정.

## 근본 원인
같은 클래스 내부 호출이라 Spring AOP 프록시를 거치지 않아 `@Transactional`이 적용되지 않았다. 트랜잭션 없이 `saveAndFlush()`가 매번 새 커넥션을 요청·반환하며 HikariPool이 반복 생성되고 고갈, SSE 스레드가 이후 DB 조회에서 커넥션을 못 얻어 블로킹됐다.
