---
type: completion-report
id: ISS-0229
created: 2026-10-07
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0229-client-errors-logged-as-error]]"
related: ["[[DEC-0104-log-4xx-warn-5xx-error]]"]
source: "https://github.com/Twin-Fang/passQL/issues/395"
---

# ISS-0229 완료 리포트: 4xx 처리기는 WARN, `CustomException`은 5xx일 때만 ERROR

GitHub #395 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
4xx 처리기 로그 WARN, `CustomException`은 5xx일 때만 ERROR.

## 근본 원인 (확정)
로그 레벨이 상태 코드를 반영하지 않았다.

## 재발 방지
배포 직후 잘못된 요청 3건(관리자 로그인 화면, 잘못된 로그인, 없는 약관 타입) → ERROR 0, WARN만 기록 (최근 1분 `4  WARN`).

## 교훈
원본에 적혀 있지 않다.
