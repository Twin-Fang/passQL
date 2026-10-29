---
type: issue
id: ISS-0222
created: 2026-10-07
topics: [progress-stats, auth-member]
symptoms: ["탈퇴회원_", "오늘의 순위", "탈퇴 회원 노출", DailySetService, getLeaderboard, WITHDRAWN]
root_cause: "`DailySetService`의 순위 조회·완료 시 순위 계산이 회원 상태(WITHDRAWN)를 보지 않았다"
status: resolved
resolution: "[[ISS-0222-withdrawn-member-in-daily-leaderboard-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/377"
---

# ISS-0222: 탈퇴한 회원이 오늘의 순위에 `탈퇴회원_xxxx`로 계속 노출됨

GitHub #377 (원본: 이슈 본문과 완료 댓글).

## 증상
회원 탈퇴 후에도 그 회원의 오늘의 세트 기록이 순위에 "탈퇴회원_xxxxxxxx"로 남아 다른 사용자에게 보이고 순위를 차지한다. 탈퇴 안내("계정과 개인정보가 삭제되고 되돌릴 수 없어요")와 맞지 않는다.

## 재현 조건
QA GitHub #357 영역 10. 오늘의 세트를 완료한 계정으로 탈퇴 → 다른 계정으로 완료 → 순위 1위에 "탈퇴회원_87f81c70 2점".

## 조사 기록
- 2026-10-07: 이슈 본문에 원인 기록.

## 근본 원인
`MemberService.withdraw`는 상태를 WITHDRAWN으로 바꾸고 닉네임을 익명화하지만, `DailySetService`의 순위 조회·완료 시 순위 계산은 회원 상태를 보지 않는다.
