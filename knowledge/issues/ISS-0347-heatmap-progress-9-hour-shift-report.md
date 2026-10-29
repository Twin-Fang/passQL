---
type: completion-report
id: ISS-0347
created: 2026-10-20
topics: [progress-stats]
status: resolved
resolves: "[[ISS-0347-heatmap-progress-9-hour-shift]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/560"
---

# ISS-0347 완료 리포트: UTC 변환을 없애고 KST 날짜를 그대로 비교

GitHub #560 리포트 댓글(`## 개요`, 2026-10-20)과 운영 실측 댓글(2026-10-21) 기준. 커밋 `1342e598`, PR #572.

## 해결 방법
- `SubmissionRepository.java`: `findSubmissionDatesByMemberUuid`(연속 학습일), `findHeatmapByMemberUuid`(히트맵)의 `DATE(submitted_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul')`를 `DATE(submitted_at)`로.
- `ProgressService.java`: 준비도 최근 학습 토픽 범위 `since`, 히트맵 조회 범위 `from`/`to`에서 KST 자정을 UTC로 바꾸던 처리 제거.
- `StreakCalculator.java`, `ProgressService.java`: "서버가 UTC 컨테이너" 주석 정정.
- `ProgressServiceHeatmapRangeTest.java`: 히트맵 범위가 KST 자정 그대로 전달되는지 확인.
- `lastStudiedAt.atZone(Asia/Seoul)`처럼 저장값을 KST 로컬로 보던 기존 코드는 원래 맞아 그대로 두었다. 관리자 대시보드 집계(GitHub #557)도 같은 기준.

## 근본 원인 (확정)
`submitted_at`은 KST 로컬 저장(운영 실측 확정)인데 집계가 UTC로 가정해 9시간 변환했다.

## 재발 방지
- 검증: `ProgressServiceHeatmapRangeTest`, `PQL-Domain-Submission` 모듈 테스트, `ProgressServiceTest`(dev DB 통합), `compileJava compileTestJava` 통과. 운영 실측으로 저장 기준 확인.
- 주의(리포트): UTC로 저장된 기간이 있었다면 그 기간 데이터는 따로 판단해야 한다(실측 결과 KST 저장으로 확정).

## 교훈
(원본에 없음, 볼트 정리) 날짜 집계가 어긋나면 주석의 전제보다 운영 DB의 최근 저장값과 실제 시각을 먼저 비교한다.
