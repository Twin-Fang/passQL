---
type: issue
id: ISS-0097
created: 2026-04-12
topics: [progress-stats, design-system]
symptoms: ["통계 페이지", StatsBarChart, recharts, "X축 0~1 소수", "카테고리별 문제 수", "합격 준비도 산출 기준", Lightbulb, StatsAnalysisCard]
root_cause: "통계 화면 요약 카드·AI 분석 카드·바 차트가 지표 의미를 전달하지 못하는 UI였다"
status: resolved
resolution: "[[ISS-0097-stats-page-ui-overhaul-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/176"
---

# ISS-0097: 통계 페이지 UI 전면 개선

GitHub #176 (원본: 이슈 본문, 목업·리포트·영상 댓글).

## 증상
- 상단 요약 카드(푼 문제 / 합격 준비도 / 연속 학습)에 아이콘이 없어 지표 맥락이 불명확.
- AI 영역 분석 카드의 아이콘·제목이 세로로 쌓이고 왼쪽 패딩이 과함. 아이콘 `Lightbulb`가 AI 맥락과 맞지 않음. 텍스트가 정적으로 표시됨.
- `카테고리별 문제 수` 바 차트 X축이 0~1 소수라 정답률인지 문제 수인지 불명확, 섹션명도 모호.
- 합격 준비도 점수 산출 기준이 사용자에게 노출되지 않음. 토픽별 막대/색상 의미가 직관적이지 않음.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록과 목업 댓글. 제안: lucide 아이콘(`CheckSquare`, `BarChart2`, `Zap`), `Sparkles` 인라인 헤더, 단어 단위 fade-in(55ms stagger), recharts 제거 후 daisyUI `progress` 기반 리스트, 합격 준비도·토픽 현황 `?` 팝오버.

## 근본 원인
원본에 적혀 있지 않다 (UI 개선 요청).
