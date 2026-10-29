---
type: issue
id: ISS-0300
created: 2026-10-16
topics: [design-system]
symptoms: [앱이 딱딱함, 연출 없이 툭 나타남, PassqlMotion.fast 하나, NoTransitionPage, PassqlBadge 의미 구분 없음, AI 해설 시트 등장 연출 없음, AI 영역 분석 카드 위치]
root_cause: "모션 토큰이 시간 1개·곡선 1개뿐이고 공통 등장 연출이 없었으며, 탭 전환이 `NoTransitionPage`라 탭을 바꿀 때마다 화면이 새로 만들어졌다"
status: resolved
resolution: "[[ISS-0300-app-motion-system-reveal-badges-report]]"
related: ["[[DEC-0136-motion-via-tokens-only]]", "[[ISS-0302-app-server-web-performance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/495"
---

# ISS-0300: 앱 모션 시스템 부재와 화면 연출 부족 (등장, 태그, AI 해설, AI 통계)

GitHub #495 (원본: 이슈 본문, 웹 모션 수치 댓글, 구현 보고서 댓글).

## 증상
- 화면과 카드가 연출 없이 한 번에 나타남.
- 모션 토큰은 `PassqlMotion.fast`(250ms)와 곡선 하나뿐. 탭 전환은 `NoTransitionPage`.
- 누를 때 반응은 투명도 변화(`PassqlPressable`) 하나.
- 태그(`PassqlBadge`)는 한 종류라 의미 구분이 안 됨.
- AI 해설 시트는 로딩이 끝나면 마크다운 글자가 그대로 교체. 헤더·단락 구분·등장 연출 없음.
- 통계 AI 영역 분석 카드는 맨 아래에 있고 연출 없음(웹 `StatsAnalysisCard`에는 있음).

## 재현 조건
해당 없음(디자인 개선).

## 조사 기록
- 2026-10-16 09:44 댓글: 웹 모션 원본 수치 표(섹션 순차 등장 300ms easeOut·지연 index×50ms, 반짝이 팝 450ms `cubic-bezier(0.34,1.56,0.64,1)`, AI 단어 등장 단어당 250ms·지연 i×55ms+200ms 등)와 앱 화면별 현재 모션 감사. 보완점: 웹에는 동작 줄이기 대응이 없음(앱은 `MediaQuery.disableAnimations`), 웹 AI 해설 시트도 진입 연출 없음, 순차 지연에 상한(웹 `FeedbackList`는 목록이 길면 지연이 끝없이 커짐).

## 근본 원인
frontmatter `root_cause`와 같음.
