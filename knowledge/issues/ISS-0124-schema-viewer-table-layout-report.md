---
type: completion-report
id: ISS-0124
created: 2026-04-13
topics: [practice]
status: resolved
resolves: "[[ISS-0124-schema-viewer-table-layout]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/225"
---

# ISS-0124 완료 리포트: 세로 스택 + 카드 내부 가로 스크롤, 인라인 style 제거

GitHub #225 `## 개요` 리포트 댓글 기준 (2026-04-13).

## 해결 방법
`client/src/components/SchemaViewer.tsx`:
- 컨테이너 `flex gap-2 overflow-x-auto` → `space-y-3`, 카드 래퍼의 `w-full min-w-0`·`scrollSnapAlign` 제거.
- 스키마 구조·샘플 데이터 카드에 `bg-surface-card`. 인라인 `style={{ }}` 전부 Tailwind/커스텀 클래스(`border-border`, `text-text-caption`, `text-brand`, `bg-accent-light`, `bg-surface-page`, `text-body`)로.
- 헤더 `Table2` 아이콘 + 테이블명, 패딩 `px-2 py-0.5` → `px-3 py-1.5`.
- 각 `<table>`만 `overflow-x-auto` 래퍼로 감싸 카드 안에서만 가로 스크롤.

## 근본 원인 (확정)
목록 전체를 감싼 가로 스크롤 컨테이너와 `min-w-0` 수축, 카드 배경색 누락.

## 재발 방지
리포트 주의사항: `bg-surface-page`, `bg-accent-light`, `text-body`는 tokens.css `@theme` 변수가 아닌 components.css/typography.css 커스텀 클래스. 짝수 행 배경은 조건부 className(빈 문자열 포함, 퍼지 영향 없음).

## 교훈
(원본에 없음, 볼트 정리) 여러 테이블이 찌그러지면 스크롤 컨테이너가 목록 전체인지 개별 테이블인지부터 본다.
