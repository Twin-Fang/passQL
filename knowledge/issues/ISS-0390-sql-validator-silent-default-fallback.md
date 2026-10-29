---
type: issue
id: ISS-0390
created: 2026-10-24
topics: ["practice", "ops-infra"]
symptoms: ["SqlSafetyValidator", "설정 조회 실패", "로그 없이 기본값", "max length 2000", "max length setting unavailable"]
root_cause: "`SqlSafetyValidator.validate`가 최대 길이 설정 조회 실패를 로그 없이 기본값(2000)으로 대체했다"
status: resolved
resolution: "[[ISS-0390-sql-validator-silent-default-fallback-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/640"
---

# ISS-0390: `SqlSafetyValidator` 설정 조회 실패를 로그 없이 기본값으로 대체함

GitHub #640 (원본: 이슈 본문과 완료 리포트 댓글).

## 증상
코드 구조 점검(2026-10-24)에서 `SqlSafetyValidator.validate`가 설정 읽기 실패를 로그 없이 기본값(2000)으로 대체하는 것을 확인했다. 설정 저장소가 깨져도 운영에서 알 방법이 없다.

## 재현 조건
설정 저장소에서 최대 길이 설정 조회가 실패할 때(원본 서술). 실제 발생 기록은 원본에 없다.

## 조사 기록
- 2026-10-24: 작업 — `catch`에서 경고 로그 한 줄(예외 종류만, 원문 메시지 제외), 기본값 대체 동작은 그대로.
- 2026-10-24: 완료 리포트(PR #641).

## 근본 원인
`catch`에서 로그 없이 기본값을 반환했다.
