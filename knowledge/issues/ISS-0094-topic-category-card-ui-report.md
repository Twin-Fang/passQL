---
type: completion-report
id: ISS-0094
created: 2026-04-12
topics: [design-system, question-bank]
status: resolved
resolves: "[[ISS-0094-topic-category-card-ui]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/169"
---

# ISS-0094 완료 리포트: `.card-topic`·`.card-topic-icon` 클래스, 토픽 이름 4개 축약

GitHub #169 리포트 댓글과 "Stable 반영 완료" 댓글 기준 (2026-04-12).

## 해결 방법
- `client/src/pages/CategoryCards.tsx`: 카드 `card-base` + 인라인 Tailwind → `card-topic`, 아이콘 래퍼 → `card-topic-icon`, 아이콘 22px → 26px.
- `client/src/styles/components.css`: `.card-topic`(16px radius, `transition: all 250ms`), `:hover`(`translateY(-3px)`, `rgba(79,70,229,0.12)` 그림자, 테두리 `#818CF8`), `:active`(`scale(0.98)` — 터치에서 `:hover`가 동작하지 않거나 지연돼서), `.card-topic-icon`(52×52px, 14px radius, `var(--color-brand-light)`).
- `V0_0_94__shorten_topic_display_names.sql`: `데이터 모델링의 이해` → `데이터 모델링`, `SQL 함수 (문자/숫자/날짜/NULL)` → `SQL 함수`, `조인 (JOIN)` → `JOIN`, `계층 쿼리 / PIVOT` → `계층 / PIVOT`.

## 근본 원인 (확정)
아이콘 배경은 프로젝트에 없는 `bg-accent-light` 클래스를 써서 렌더링되지 않았다.

## 재발 방지
리포트 주의사항: 토픽 이름 변경은 Flyway(`V0_0_94`)라 서버 재시작 시 자동 적용. 관리자 토픽 편집 미구현은 별도 이슈로 등록했다고 적었다(원본 표기 #170, 실제 처리 이슈는 GitHub #168).

## 교훈
(원본에 없음, 볼트 정리) Tailwind 클래스가 아무 효과가 없으면 그 토큰이 테마에 정의돼 있는지부터 본다.
