---
type: issue
id: ISS-0169
created: 2026-04-27
topics: [progress-stats]
symptoms: ["레이더 차트", "미학습 토픽 0", "차트 중앙 한 점", StatsRadarChart, PolarRadiusAxis, recharts, "그물 형태"]
root_cause: "미학습 토픽 값 0과 recharts 축 자동 스케일 때문에 차트가 선·뾰족한 모양으로 표시"
status: resolved
resolution: "[[ISS-0169-radar-chart-untrained-topic-minimum-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/315"
---

# ISS-0169: 통계 레이더 차트가 미학습 토픽 때문에 그물 형태를 잃음

GitHub #315 (원본: 이슈 본문과 리포트 댓글). 기능 개선 이슈.

## 증상
통계 페이지 토픽별 레이더 차트에서 학습 이력이 없는 토픽(정답률 0%)이 중앙 한 점에 모이고, 학습 토픽이 1~2개면 그 꼭짓점만 뻗어 선이나 뾰족한 모양이 된다. 전체 토픽 커버리지를 한눈에 보기 어렵다.

## 재현 조건
학습한 토픽이 1~2개뿐인 계정으로 통계 페이지 진입.

## 조사 기록
- 2026-04-27: 대상 `client/src/components/StatsRadarChart.tsx`.

## 근본 원인
recharts `RadarChart`가 데이터 최댓값 기준으로 축 스케일을 자동 조정하고, 미학습 토픽 값이 0이었다.
