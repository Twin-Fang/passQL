---
type: issue
id: ISS-0045
created: 2026-04-10
topics: [ops-infra]
symptoms: [SandboxPool, sandbox.pool.concurrency, sandbox.pool.wait_seconds, "@Value", application.yml, app_setting, AppSettingService.getInt, Semaphore, "재배포 없이 조정 불가"]
root_cause: "SandboxPool의 concurrency·wait_seconds가 application.yml @Value로만 로딩되고, 두 키가 app_setting 테이블에 없었다"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/75"
---

# ISS-0045: SandboxPool 동시 실행 슬롯·대기 시간이 yml 하드코딩이라 운영 중 조정 불가

GitHub #75 (원본: 이슈 본문만, 댓글 없음). `작업완료` 라벨로 2026-04-10에 닫혔으나 완료 댓글은 없다.

## 증상
`SandboxPool`의 동시 실행 슬롯 수(`concurrency`)와 슬롯 대기 최대 시간(`wait_seconds`)이 `application.yml`의 `@Value`로만 로딩되어 재배포 없이 바꿀 수 없다. `concurrency`는 기동 시 Semaphore 초기화에, `wait_seconds`는 매 `acquire()`에 쓰인다. 두 키(`sandbox.pool.concurrency`, `sandbox.pool.wait_seconds`)가 `app_setting`에 없어 기동 시 `AppSettingService.getInt()` 호출이 실패할 위험이 있다.

## 재현 조건
운영 중 부하로 동시 슬롯 수를 늘려야 할 때. DB `app_setting`에 키가 없으면 `AppSettingService.getInt()` 예외 또는 yml 값 고정.

## 조사 기록
- 2026-04-10: 이슈 본문 예상 동작 — 두 키를 `app_setting` 시드로 두고, `AppInitializer`가 DB 값을 Redis에 워밍업해 `SandboxPool.init()`이 Semaphore를 초기화, `wait_seconds`는 `acquire()`마다 실시간으로 읽는다. 참고 자료에 `V0_0_45__add_sandbox_pool_settings.sql`, `AppInitializer.java`, `SandboxPool.java`가 적혀 있다. 실제 수정 내용은 원본에 적혀 있지 않다.

## 근본 원인
튜닝 값이 yml에만 있었고 `app_setting` 시드가 없었다.
