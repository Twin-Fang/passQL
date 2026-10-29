---
type: issue
id: ISS-0156
created: 2026-04-25
topics: [home]
symptoms: [excludeQuestionUuids, seenUuids, "Request header is too large", "400", "CORS 에러로 보임", "추천 새로고침", Http11InputBuffer, "/api/questions/recommendations"]
root_cause: "제외 UUID를 GET 쿼리스트링으로 보내고 프론트 `seenUuids`가 리셋 없이 누적되어 URL이 Tomcat 헤더 한도(8KB)를 넘음"
status: resolved
resolution: "[[ISS-0156-recommendation-exclude-uuids-header-overflow-report]]"
related: ["[[DEC-0084-recommendation-exclusion-post-body-fifo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/291"
---

# ISS-0156: 홈 추천 새로고침 반복 시 `excludeQuestionUuids` 누적으로 Tomcat 헤더 한도 초과 → 400

GitHub #291 (원본: 이슈 본문과 구현 보고서 댓글).

## 증상
홈 화면 AI 추천 문제를 새로고침할 때마다 `excludeQuestionUuids` 파라미터가 세션 안에서 무제한 누적되어, 반복하면 요청 URL이 Tomcat 기본 헤더 한도(8KB)를 넘는다. 서버 로그:
```
java.lang.IllegalArgumentException: Request header is too large
at org.apache.coyote.http11.Http11InputBuffer.fill(Http11InputBuffer.java:780)
```
브라우저 콘솔에는 CORS 에러로 보인다(서버가 400을 CORS 헤더 없이 반환).

## 재현 조건
1. 홈 진입 → 추천 3개 수신 → `seenUuids` 3개 누적
2. 새로고침 반복 → 요청마다 제외 UUID 3개씩 추가
3. 약 30회 이상 새로고침 시 URL 8KB 초과 → 예외

## 조사 기록
- 2026-04-25: 원인 확인 — `GET /api/questions/recommendations?excludeQuestionUuids=...` 쿼리스트링 방식, 프론트 `seenUuids` state 리셋 없음.

## 근본 원인
제외 목록을 URL 쿼리로 전달하는 구조와 클라이언트 누적 목록의 상한 부재.
