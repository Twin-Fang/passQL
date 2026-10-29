---
type: completion-report
id: ISS-0023
created: 2026-04-08
topics: [home, practice]
status: resolved
resolves: "[[ISS-0023-random-question-recommendations-api]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/27"
---

# ISS-0023 완료 리포트: MariaDB `RAND()` 기반 추천 API, 오늘의 챌린지 자동 제외

GitHub #27 `## 개요` 리포트 댓글(2026-04-08) 기준.

## 해결 방법
- `QuestionController`: `GET /api/questions/recommendations`(`size` 기본 3, `excludeQuestionUuid` 선택).
- `QuestionService.getRecommendations`: `Math.max(1, Math.min(size, 5))`로 clamp. `excludeQuestionUuid`가 null이면 `DailyChallengeRepository.findByChallengeDate(LocalDate.now())`의 문제를 제외.
- `QuestionRepository`: `findRandomActive(int size)`(`ORDER BY RAND() LIMIT :size`), `findRandomActiveExcluding`. (이슈 본문은 Postgres `ORDER BY RANDOM()`을 적었지만 구현은 MariaDB `RAND()`.)
- DTO: `RecommendationsResponse`, `QuestionSummary`(stemPreview 앞 100자). `QuestionServiceTest` 4케이스. `docs/apilog/2026-04-08-add-recommendations-endpoint.md`.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 주의사항: 화면 연결은 D5. 활성 문제 0개면 빈 리스트. `RAND()` 쿼리는 데이터가 매우 많아지면 성능 저하 가능 — 문제 수 증가 시 검토.

## 교훈
원본에 적혀 있지 않다.
