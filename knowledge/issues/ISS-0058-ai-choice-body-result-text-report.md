---
type: completion-report
id: ISS-0058
created: 2026-04-11
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0058-ai-choice-body-result-text]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/103"
---

# ISS-0058 완료 리포트: body SQL 형식 사전 검사, 프롬프트 v2, SSE 마지막 청크 처리

GitHub #103 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
- `SandboxValidator.validateStandard()`: 실행 전에 `body`가 `SELECT` 또는 `WITH`로 시작하는지 검사, 아니면 DB 커넥션 없이 즉시 ERROR + WARN 로그.
- `V0_0_59__fix_choice_set_prompt.sql`: `generate_choice_set` v1 비활성화, v2 추가 — system_prompt에 "body는 반드시 MariaDB에서 실행 가능한 SELECT SQL 쿼리"와 올바른·금지 예시.
- `client/src/api/questions.ts`: SSE 파싱을 `processBuffer()`로 추출하고, `done=true`일 때 `buffer.trim()` 잔여 내용에 `"\n\n"`을 붙여 강제 파싱.

## 근본 원인 (확정)
이슈 노트와 같다. 리포트: 서버가 `emitter.send(errorEvent)` → `emitter.complete()`를 호출하면 error 이벤트가 마지막 TCP 청크에 담겨 오는데 `done=true` 분기가 버퍼를 버렸다. 기존에는 4개 × 3회 = 최대 12번의 불필요한 HikariPool 생성·해제가 있었다.

## 재발 방지
리포트 주의사항: `startsWith("SELECT"/"WITH")`는 `(SELECT ...)`나 `EXPLAIN SELECT`를 막을 수 있다. v2는 마이그레이션 실행(서버 재시작) 후 유효하고 기존 `status=FAILED` 기록에는 소급되지 않는다. 마이그레이션으로 프롬프트 버전을 바꾸므로 롤백 가능.

## 교훈
(원본에 없음, 볼트 정리) SSE 화면이 스피너에서 멈추면 서버가 보낸 마지막 이벤트를 클라이언트 파서가 스트림 종료 시 처리하는지부터 본다.
