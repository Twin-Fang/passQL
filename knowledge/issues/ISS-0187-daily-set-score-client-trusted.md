---
type: issue
id: ISS-0187
created: 2026-10-06
topics: [practice, security]
symptoms: [리더보드 점수 조작, correctCount, "POST /api/daily-set/complete", 클라이언트 점수 신뢰, 데일리 세트 만점]
root_cause: "`POST /api/daily-set/complete`가 클라이언트가 보낸 `correctCount`를 검증 없이 저장했다"
status: resolved
resolution: "[[ISS-0187-daily-set-score-client-trusted-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/342"
---

# ISS-0187: 데일리 세트 리더보드 점수를 클라이언트 값 그대로 저장해 조작 가능

GitHub #342 (원본: 이슈 본문과 댓글).

## 증상
`POST /api/daily-set/complete`가 클라이언트가 보낸 `correctCount`를 검증 없이 저장한다. 요청 한 번으로 만점을 보낼 수 있어 리더보드 점수 조작이 가능하다 (GitHub #339 확인된 위험 1번).

## 재현 조건
`correctCount`를 부풀린 완료 요청을 보내면 그대로 저장된다.

## 조사 기록
- 2026-10-06: 예상 동작 정리 — 점수는 서버가 이 세션(`sessionUuid`)의 실제 채점 기록으로 계산, 오늘 세트 밖 문제·다른 회원 세션 제외, 같은 문제 반복 제출은 첫 제출만, 인정할 제출이 없거나 `sessionUuid`가 없으면 거절.

## 근본 원인
점수 계산을 클라이언트 값에 맡겼다.
