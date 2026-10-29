---
type: issue
id: ISS-0101
created: 2026-04-12
topics: [design-system]
symptoms: [card-base, filter-dropdown, badge-topic, Questions.tsx, components.css]
root_cause: "Questions.tsx에 커스텀 CSS 클래스(card-base, filter-dropdown)가 가장 많이 남아 있었다"
status: resolved
resolution: "[[ISS-0101-questions-page-tailwind-utilities-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/183"
---

# ISS-0101: Questions.tsx 커스텀 CSS를 Tailwind 유틸리티로 교체

GitHub #183 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
`Questions.tsx`에 `card-base` 4곳(스켈레톤 2, 토픽 카드, 문제 카드), `filter-dropdown` 2곳(이 파일 단독 사용), `badge-topic` 1곳.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. `card-base` → `bg-surface-card border border-border rounded-2xl p-4 sm:p-6`, `filter-dropdown` → Tailwind 후 CSS 삭제, `badge-topic`은 passQL 전용 인디고 배지라 유지. 다른 파일의 `card-base` 12곳은 별도 이슈(GitHub #187).

## 근본 원인
커스텀 CSS 클래스 잔존.
