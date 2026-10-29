---
type: completion-report
id: ISS-0123
created: 2026-04-13
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0123-stem-card-choice-card-distinction]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/224"
---

# ISS-0123 완료 리포트: "문제" 라벨 상시 노출과 인디고 지문 카드

GitHub #224 작업 리포트 댓글 기준 (2026-04-13).

## 해결 방법
- `client/src/pages/QuestionDetail.tsx`: 접힌 상태에서만 보이던 `BookOpen` 대신 항상 보이는 라벨(12px `BookOpen` + "문제", xs semibold uppercase). 지문 카드 "C1 디자인": `bg-surface-card` → `bg-brand-light`(#EEF2FF), `border-border` → `border-brand-medium`.
- `client/src/components/SchemaViewer.tsx`: 샘플 데이터 카드 상단에 `Table2` 아이콘 + 테이블명 헤더(댓글 제안 패턴).
- `client/src/components/SqlPlayground.tsx`: 패딩을 헤더 `button` 안으로 옮기고 `hover:bg-surface transition-colors` — 헤더 전체 행이 클릭 영역.
- `ChoiceCard`는 수정 없음.

## 근본 원인 (확정)
지문 카드와 선택지 카드의 동일 스타일, 펼침 상태 아이콘 제거.

## 재발 방지
리포트 참고사항: `bg-brand-light`, `border-brand-medium`은 디자인 토큰(`#EEF2FF`, `#818CF8`)으로 정의된 커스텀 클래스. "C1 디자인"을 다른 시안과 비교해 고른 기록은 원본에 없다.

## 교훈
논의 기록 없음.
