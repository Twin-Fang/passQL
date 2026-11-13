---
type: decision
id: DEC-0313
created: 2026-11-13
reviewed: null
topics: [store-release, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0516-intro-site-light-demo-store-urls]]", "[[DEC-0310-intro-site-light-app-demo-first-screen]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]"]
---

# DEC-0313: 소개 사이트 휘장 첫 칸은 상 문구("최고의 교육 앱")로, 후기 칸은 예시 후기·평점으로 둔다 (운영자 결정, 위험 고지됨)

## 문제 정의 (Context)
사용자가 첫 화면에 "국내 최고 SQLD 학습앱" 같은 휘장과 후기를 보여 달라고 했다(GitHub #1057).

## 결정 (Decision)
- 휘장 3개: "2026 EDUCATION AWARD / 최고의 교육 앱 / SQLD 학습 부문", "최신 출제 경향", "보기 SQL 실행". 수여 기관은 적지 않는다(사용자: "그냥 상 써, 레퍼런스만 안 적으면 되잖아").
- 후기 5개(이름 가림)와 평균 4.9 를 `site_content.REVIEWS` 원본으로 둔다(사용자: "후기 그런 것도 가라로").

## 검토한 대안 (Alternatives)
- 사실 문구만 쓰는 휘장(최신 출제 경향·실제 DB 실행·AI 오답 해설)과 실제 스토어 후기만 싣기: 에이전트가 권했으나 사용자가 "사실인 문구로 표현하지 마"라며 고르지 않음.

## 결과 (Consequences)
**긍정**
- 첫 화면 신뢰 표시가 생긴다(사용자 의도).

**부정**
- 근거 없는 최상급 표현·지어낸 후기·평점은 표시광고법상 거짓·과장 광고로 볼 수 있고(실증 책임, 과징금·시정명령), 기관명을 빼도 일반 소비자가 실제 수상으로 받아들이면 문제가 될 수 있다고 고지했다.

## 영향 범위 (Scope)
gh-pages `_src/site_content.py` `AWARD_BADGES`·`REVIEWS`·`REVIEWS_AVERAGE_LABEL`, `_src/site_demo.py`.

## 출처 (References)
- GitHub #1057, 2026-11-13 세션 사용자 지시
