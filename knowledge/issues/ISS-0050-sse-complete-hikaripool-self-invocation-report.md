---
type: completion-report
id: ISS-0050
created: 2026-04-11
topics: [practice, ops-infra]
status: resolved
resolves: "[[ISS-0050-sse-complete-hikaripool-self-invocation]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/91"
---

# ISS-0050 완료 리포트: save 전담 빈 `ChoiceSetSaveService` 분리

GitHub #91 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
- `ChoiceSetSaveService` 신규(`PQL-Domain-Question`): `saveSuccess()`, `saveConceptSuccess()`, `saveFailed()`를 별도 `@Service` 빈으로 분리해 외부 빈 호출로 프록시를 거치게 했다.
- `ChoiceSetGenerationService`: 리포지토리 의존과 save 메서드 3개 제거, `ChoiceSetSaveService` 주입.
- `ChoiceSetResolver`: `resolveForUser()`의 `@Transactional` 제거(장시간 트랜잭션 방지), 프리페치 `consumed_at` 마킹을 `markConsumed()`(`@Transactional`)로 분리.

## 근본 원인 (확정)
`@Transactional` self-invocation으로 트랜잭션 미적용 → 커넥션 풀 고갈 → SSE 스레드 블로킹. 첫 문제는 커넥션이 남아 있어 정상이었다.

## 재발 방지
리포트 주의사항: `ChoiceSetSaveService`에는 조회 로직을 넣지 않는다. `markConsumed()`는 `ChoiceSetResolver` 내 `protected @Transactional`이라 외부에서 호출되는 구조를 유지해야 같은 문제를 피한다.

## 교훈
(원본에 없음, 볼트 정리) 서버 로그에 HikariPool 번호가 계속 올라가면 `@Transactional` self-invocation을 먼저 의심한다.
