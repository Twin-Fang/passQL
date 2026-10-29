---
type: completion-report
id: ISS-0097
created: 2026-04-12
topics: [progress-stats, design-system]
status: resolved
resolves: "[[ISS-0097-stats-page-ui-overhaul]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/176"
---

# ISS-0097 완료 리포트: 통계 화면 아이콘·AI 카드·토픽 리스트·설명 팝오버

GitHub #176 `## 개요` 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `src/pages/Stats.tsx`: 요약 카드 3개에 lucide-react 아이콘. `StatsBarChart` → `StatsTopicList`. 합격 준비도 `?` 버튼 + `ReadinessPopover`(정답률·범위·꾸준함 미니 바).
- `src/components/StatsAnalysisCard.tsx`: `Lightbulb` → `Sparkles`, 아이콘+제목 한 줄, `animateWords`로 단어 `span.ai-word` 55ms stagger. 제목 `AI 한마디`로 확정.
- `src/components/StatsTopicList.tsx`(신규): 막대 길이 = 푼 문제 수, 색상 뱃지 = 정답률 구간(80%↑ 초록 / 60%↑ 인디고 / 40%↑ 노랑 / 40%↓ 빨강), 미학습 회색, 범례, `TopicListPopover`.
- `src/components/StatsRadarChart.tsx`: 제목 `영역별 분석` → `토픽별 분석`, `text-lg` → `text-base`.
- `src/styles/components.css`: `ai-word-in`, `ai-header-slide`, `sparkle-pop`, `popover-in` 애니메이션.

## 근본 원인 (확정)
원본에 적혀 있지 않다 (UI 개선). 구현 중 문제: `animate-stagger`의 `animation` 속성이 새 stacking context를 만들어 내부 z-index가 격리됨 → 두 팝오버를 `createPortal`로 `document.body`에 렌더링하고 `getBoundingClientRect()` + `fixed` 포지셔닝으로 배치.

## 재발 방지
리포트 주의사항: `StatsBarChart.tsx`는 미사용으로 남아 있음(삭제는 사용자 승인 후). 팝오버의 동적 수치(`top`, `left`, 미니 바 `width`)는 인라인 `style` 사용 중.

## 교훈
(원본에 없음, 볼트 정리) 애니메이션이 걸린 컨테이너 안의 팝오버가 가려지면 stacking context 격리를 의심하고 portal 렌더링을 검토한다.
