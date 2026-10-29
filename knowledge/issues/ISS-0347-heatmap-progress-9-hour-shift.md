---
type: issue
id: ISS-0347
created: 2026-10-20
topics: [progress-stats]
symptoms: ["9시간 밀림", "학습 히트맵 날짜", "다음 날 칸", submitted_at, "AT TIME ZONE 'UTC'", "TZ=Asia/Seoul", SubmissionRepository, ProgressService, "연속 학습일", "KST 15시"]
root_cause: "submitted_at은 KST 로컬로 저장되는데 히트맵·진도 집계가 UTC 저장으로 가정하고 9시간을 변환했다"
status: resolved
resolution: "[[ISS-0347-heatmap-progress-9-hour-shift-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/560"
---

# ISS-0347: 학습 히트맵과 진도 날짜 범위가 9시간 밀림

GitHub #560 (원본: 이슈 본문과 댓글).

## 증상
- 서버 컨테이너는 `TZ=Asia/Seoul`(`server/Dockerfile` 11행 `ENV TZ=Asia/Seoul`, `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`의 `-e TZ=Asia/Seoul`)이고 `SubmissionService`의 `LocalDateTime.now()`로 저장하므로 `submission.submitted_at`은 KST.
- `SubmissionRepository` 히트맵 쿼리는 `submitted_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul'`로 +9시간 변환 → KST 15시 이후 풀이가 다음 날 칸에 잡힌다.
- `ProgressService`(준비도 범위, 오늘 범위)는 KST 자정을 UTC로 바꿔 조회 → 범위가 전날 15시부터 시작.
- 코드 주석이 잘못된 전제를 적고 있었다: 히트맵 쿼리 "submitted_at은 UTC TIMESTAMP로 저장되므로", `ProgressService` 69, 91, 156, 166행 "서버가 UTC Docker 컨테이너에서 실행되므로".

## 재현 조건
KST 15시~24시 사이에 문제를 풀고 앱·웹 학습 히트맵에서 그날 칸을 확인(다음 날 칸에 표시될 것으로 예상).

## 조사 기록
- 2026-10-20: GitHub #557(관리자 대시보드) 코드 리뷰 중 발견. 운영 데이터 미확인.
- 2026-10-21: 운영 DB `max(submitted_at)` = `2026-10-21 15:15:25`, 같은 시각 KST 현재 `15:32:13`(DB 세션 TimeZone `Etc/UTC`) → KST 로컬 저장 확정.

## 근본 원인
저장 기준(KST 로컬)과 집계 기준(UTC 가정)이 달랐다. 잘못된 "UTC 컨테이너" 전제 주석이 그대로 남아 있었다.
