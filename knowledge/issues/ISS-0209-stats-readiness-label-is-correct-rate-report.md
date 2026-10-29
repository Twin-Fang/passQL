---
type: completion-report
id: ISS-0209
created: 2026-10-07
topics: [progress-stats]
status: resolved
resolves: "[[ISS-0209-stats-readiness-label-is-correct-rate]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/364"
---

# ISS-0209 완료 리포트: 통계 상단 카드 라벨을 "정답률"로 정정

GitHub #364 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
통계 상단 카드 라벨 "합격 준비도" → "정답률" (값은 `progress.correctRate` 그대로). 홈의 합격 준비도(31%)와 통계의 정답률(38%)이 서로 다른 지표임을 화면에서 구분.

## 근본 원인 (확정)
`progress.correctRate`에 "합격 준비도" 라벨을 붙임.

## 재발 방지
`stats_widgets_test.dart` 통과.

## 교훈
(원본에 없음, 볼트 정리) 같은 이름의 지표는 같은 값이어야 한다(이슈 본문 기대 동작) — 화면 간 수치가 다르면 라벨과 데이터 필드부터 대조한다.
