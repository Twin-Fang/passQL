---
type: decision
id: DEC-0084
created: 2026-04-25
reviewed: null
topics: [home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0156-recommendation-exclude-uuids-header-overflow]]", "[[ISS-0156-recommendation-exclude-uuids-header-overflow-report]]", "[[ISS-0173-app-api-client-server-alignment]]"]
---

# DEC-0084: 추천 제외 목록은 GET 쿼리가 아니라 POST 본문으로 보내고, 클라이언트는 최신 30개만 유지한다

## 문제 정의 (Context)
홈 추천 새로고침을 반복하면 `excludeQuestionUuids` 쿼리스트링이 누적되어 Tomcat 헤더 한도(8KB)를 넘고 400이 났다 (GitHub #291).

## 결정 (Decision)
- 추천 API를 `@GetMapping` → `@PostMapping`으로 바꾸고 제외 UUID는 `RecommendationsRequest` 본문으로 받는다.
- 클라이언트 `seenUuids`는 최신 30개만 유지한다(FIFO, 이중 방어).

## 검토한 대안 (Alternatives)
- 기존 GET 쿼리스트링 방식: URL 길이 한도 문제로 버림(원본 "URL 길이 제한 문제 근본 해결").
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 새로고침 횟수와 무관하게 URL 길이 한도에 걸리지 않는다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`QuestionController.java`, `RecommendationsRequest.java`, `client/src/api/questions.ts`, `client/src/pages/Home.tsx`. 앱 API 클라이언트도 이후 `POST /questions/recommendations`(`size`, `excludeQuestionUuids`)로 맞췄다(GitHub #328).

## 출처 (References)
- GitHub #291 이슈 본문 "해결 방법", 구현 보고서 댓글(2026-04-25)
- GitHub #328 이슈 본문(앱 정합 이유로 #291 언급)
