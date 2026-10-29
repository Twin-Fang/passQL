---
type: completion-report
id: ISS-0187
created: 2026-10-06
topics: [practice, security]
status: resolved
resolves: "[[ISS-0187-daily-set-score-client-trusted]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/342"
---

# ISS-0187 완료 리포트: 데일리 세트 점수를 서버의 세션 제출 기록으로 계산

GitHub #342 완료 댓글 기준 (커밋 `2df691a`, 2026-10-06 운영 배포). `## 개요` 형식 리포트는 없음.

## 해결 방법
데일리 세트 점수를 클라이언트 값이 아니라 서버의 세션 제출 기록으로 계산한다: 오늘 세트 문제만, 같은 문제는 첫 제출만 인정, `sessionUuid` 필수, 인정할 제출이 없으면 거절.

## 근본 원인 (확정)
클라이언트가 보낸 `correctCount`를 그대로 저장.

## 재발 방지
단위 테스트 6개(부풀린 점수 무시, 반복 제출, 세트 외 문제, 제출 없음, 세션 없음, 중복 완료). 운영 배포 후 `/actuator/health` 200, 토큰 없는 호출 401.

## 교훈
(원본에 없음, 볼트 정리) 순위·점수처럼 경쟁에 쓰이는 값은 클라이언트가 보낸 집계값을 저장하지 말고 서버 기록으로 다시 계산한다.
