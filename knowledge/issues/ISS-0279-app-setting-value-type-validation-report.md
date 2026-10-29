---
type: completion-report
id: ISS-0279
created: 2026-10-15
topics: [admin, ops-infra]
status: resolved
resolves: "[[ISS-0279-app-setting-value-type-validation]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/473"
---

# ISS-0279 완료 리포트: `AppSettingValueType` 저장 전 형식 검사와 "재시작 후 반영" 배지

GitHub #473 구현 보고서 댓글 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- `AppSettingValueType`(INT, FLOAT, BOOLEAN, STRING)으로 저장 전 형식 검사. 틀리면 400 `INVALID_INPUT_VALUE`와 "{key} 값은 {타입} 형식이어야 합니다."
- 기동 시 한 번만 읽는 항목(`sandbox.pool.concurrency`)은 화면에 "재시작 후 반영" 배지. 대상 목록은 `AppSettingKeys.RESTART_REQUIRED_KEYS` 한 곳.
- 저장 실패 시 서버 메시지를 입력칸 아래에 표시.
- 검증: `AppSettingServiceValueTypeTest` 3건, 서버 전체 96개 중 95개 통과.

## 근본 원인 (확정)
설정 저장 경로에 타입 검사가 없었다.

## 재발 방지
저장 전 타입 검사. 재시작 필요 항목은 `AppSettingKeys.RESTART_REQUIRED_KEYS`에 등록한다.

## 교훈
(원본에 없음, 볼트 정리) 런타임 설정을 화면에서 바꿀 수 있게 하면 저장 시점 검증과 "언제 반영되는지" 표시가 함께 필요하다.
