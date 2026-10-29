---
type: completion-report
id: ISS-0222
created: 2026-10-07
topics: [progress-stats, auth-member]
status: resolved
resolves: "[[ISS-0222-withdrawn-member-in-daily-leaderboard]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/377"
---

# ISS-0222 완료 리포트: `DailySetService.visibleBoard`로 탈퇴·회원 없는 기록 제외

GitHub #377 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`DailySetService.visibleBoard`: 오늘 기록 중 회원 상태가 WITHDRAWN이거나 회원 정보가 없는 기록을 제외. 순위 조회(`getLeaderboard`)와 완료 응답의 내 순위·참가자 수(`complete`) 모두 적용 → 순위가 당겨진다.

## 근본 원인 (확정)
순위 계산이 회원 상태를 보지 않았다.

## 재발 방지
`LeaderboardWithdrawnMemberTest` 추가(탈퇴 회원 제외 + 순위 1위로 당겨짐), 기존 일일 세트 테스트 포함 9건 통과. 배포 후 실측: "탈퇴회원_87f81c70"이 사라지고 남은 회원이 1위.

## 교훈
(원본에 없음, 볼트 정리) 탈퇴는 회원 행을 지우지 않고 상태만 바꾸므로, 다른 사용자에게 보이는 집계(순위 등)는 회원 상태를 따로 걸러야 한다.
