---
type: completion-report
id: ISS-0069
created: 2026-04-12
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0069-questions-detail-page-ui-polish]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/120"
---

# ISS-0069 완료 리포트: 카드 hover 패턴 통일, 토픽 아이콘 상수, QuestionDetail 전체화면 분리

GitHub #120 작업 댓글 기준 (2026-04-12). `## 개요` 형식은 아니고 "작업 개요" 형식.

## 해결 방법
- `src/constants/topicIcons.ts` 신규: 토픽 코드 9개 → lucide-react 아이콘 `TOPIC_ICON_MAP`, `getTopicIcon()` (예: `sql_join` → Combine, `sql_window` → AppWindow).
- `Questions.tsx`·`Home.tsx`: 클릭 가능한 카드에 `hover:shadow-md hover:-translate-y-0.5 hover:border-brand transition-all duration-200` 패턴, 카드 `shadow-sm`. 토픽 카드 중복 캡션 제거.
- `src/App.tsx`: `/questions/:questionUuid`를 AppLayout 밖으로 옮겨 하단 탭·사이드바 없는 전체화면 집중 모드로. 이유는 "네비게이션 요소가 공간을 차지하지 않도록". DailyChallenge·PracticeSet과 같은 라우팅 패턴.
- `ChoiceCard`·`ChoiceReview` `shadow-sm`, `btn-primary`·`btn-secondary`·`btn-compact`에 `shadow`.
- 추천 문제 `Link`에 `className="block"` (inline이라 `space-y-3`이 안 먹던 문제).

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
특이사항: `topicIcons.ts`는 만들었지만 Questions.tsx 카드 렌더링에는 아직 미적용, 후속 작업 예정.

## 교훈
원본에 적혀 있지 않다.
