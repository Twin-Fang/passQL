---
type: issue
id: ISS-0279
created: 2026-10-15
topics: [admin, ops-infra]
symptoms: [앱 설정 타입 검증 없음, valueType, "SandboxPool getInt 실패", "SQL 실행 전체 500", sandbox.pool.concurrency, 재시작 전 미반영]
root_cause: "관리자 앱 설정 저장이 `valueType`을 검사하지 않아 정수 항목에 잘못된 값이 들어가면 `SandboxPool.getInt`가 실패했다"
status: resolved
resolution: "[[ISS-0279-app-setting-value-type-validation-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/473"
---

# ISS-0279: 관리자 앱 설정 저장 시 값 타입 검증 없음

GitHub #473 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- `valueType`(INT 등)을 검증하지 않고 저장. 잘못된 값이면 `SandboxPool` `getInt` 실패로 SQL 실행 전체가 500.
- `sandbox.pool.concurrency`는 기동 시 한 번만 읽어 화면에서 바꿔도 재시작 전까지 반영 안 됨.
- 위치: `server/PQL-Web/.../AdminSettingController.java:29`, `SandboxPool.java:52,63`.

## 재현 조건
관리자 설정 화면에서 정수 항목에 정수가 아닌 값을 저장.

## 조사 기록
- 2026-10-15: 예상 동작 — 타입별 서버 검증과 오류 안내, 재시작이 필요한 항목은 화면에 표시하거나 런타임 반영.

## 근본 원인
frontmatter `root_cause`와 같음.
