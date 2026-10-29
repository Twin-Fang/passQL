---
type: issue
id: ISS-0229
created: 2026-10-07
topics: [ops-infra]
symptoms: ["4xx ERROR 로그", "로그 레벨", GlobalExceptionHandler, "실제 장애 로그가 묻힘"]
root_cause: "`GlobalExceptionHandler`가 클라이언트 오류(4xx)를 전부 ERROR 레벨로 기록했다"
status: resolved
resolution: "[[ISS-0229-client-errors-logged-as-error-report]]"
related: ["[[DEC-0104-log-4xx-warn-5xx-error]]"]
source: "https://github.com/Twin-Fang/passQL/issues/395"
---

# ISS-0229: 클라이언트 오류(4xx)가 전부 ERROR로 기록돼 실제 장애 로그가 묻힘

GitHub #395 (원본: 이슈 본문과 완료 댓글).

## 증상
타입 불일치·검증 실패·세션 없음 같은 4xx가 전부 ERROR 레벨로 기록돼 실제 장애 로그가 묻힌다.

## 재현 조건
해당 없음 (기능 개선). 잘못된 요청을 보내면 ERROR 로그가 남는 상태.

## 조사 기록
- 2026-10-07: 대상 `GlobalExceptionHandler`.

## 근본 원인
예외 처리기가 상태 코드와 무관하게 ERROR로 기록했다.
