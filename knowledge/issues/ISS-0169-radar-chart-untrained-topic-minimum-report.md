---
type: completion-report
id: ISS-0169
created: 2026-04-27
topics: [progress-stats]
status: resolved
resolves: "[[ISS-0169-radar-chart-untrained-topic-minimum]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/315"
---

# ISS-0169 완료 리포트: 미학습 토픽 표시값 10, 축 도메인 `[0, 100]` 고정

GitHub #315 `## 개요` 리포트 댓글(2026-04-27) 기준.

## 해결 방법
`client/src/components/StatsRadarChart.tsx`
- 미학습 토픽(정답률 0%) value `0` → `10`(시각적 최솟값).
- `PolarRadiusAxis` 추가: `domain={[0, 100]}` 고정, `tick={false}`, `axisLine={false}`.
- 10으로 정한 이유(원본): 학습 데이터가 있는 토픽(최소 1% 이상)과 구분되면서 차트 비율상 튀지 않는 수치로 조정.

## 근본 원인 (확정)
recharts 자동 스케일 + 미학습 토픽 0 값.

## 재발 방지
리포트 주의사항: 표시값 10은 실제 정답률이 아니다. 툴팁·수치 레이블을 추가하면 실제 값(0%)과 표시값(10)의 불일치가 드러나므로 별도 처리가 필요하다.

## 교훈
(원본에 없음, 볼트 정리) 차트에 시각 보정값을 넣었으면 수치 노출(툴팁·레이블) 추가 시 실제 값으로 바꿔 보여 준다.
