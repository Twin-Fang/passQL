---
type: completion-report
id: ISS-0218
created: 2026-10-07
topics: [progress-stats]
status: resolved
resolves: "[[ISS-0218-readiness-recency-new-user-70]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/373"
---

# ISS-0218 완료 리포트: 학습 기록이 없으면 최신성 `RECENCY_NONE = 0.0`

GitHub #373 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`ReadinessCalculator.computeRecency`: `lastStudiedAt == null`이면 `RECENCY_NONE = 0.0`. 15일 이상 쉰 경우의 바닥값 0.70(`RECENCY_DEFAULT`)은 유지. score는 원래도 0이라 합격 준비도 값에는 영향이 없고 화면의 "최신성" 표시만 정확해진다.

## 근본 원인 (확정)
기록 없음과 오래 쉰 경우를 구분하지 않았다.

## 재발 방지
`ReadinessRecencyTest` 3건(기록 없음 0 / 30일 휴식 0.70 / 오늘 학습 1.0) 통과. `PQL-Domain-Submission` 모듈 테스트 소스는 기존 테스트(`ProgressServiceTest` 등)가 깨져 컴파일되지 않아 테스트를 PQL-Web 쪽에 두었다(GitHub #405에서 다룸). 배포 후 실측: 탈퇴 → 같은 구글 계정 재가입 → 홈 최신성 0%.

## 교훈
(원본에 없음, 볼트 정리) 지표의 바닥값은 "데이터가 오래됨"과 "데이터가 없음"을 따로 다뤄야 한다.
