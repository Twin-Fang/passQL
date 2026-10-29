---
type: completion-report
id: ISS-0156
created: 2026-04-25
topics: [home]
status: resolved
resolves: "[[ISS-0156-recommendation-exclude-uuids-header-overflow]]"
related: ["[[DEC-0084-recommendation-exclusion-post-body-fifo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/291"
---

# ISS-0156 완료 리포트: 추천 API를 POST 본문으로 전환하고 `seenUuids` FIFO 30개 제한

GitHub #291 구현 보고서 댓글(2026-04-25) 기준.

## 해결 방법
1. GET → POST 전환: 제외 UUID 목록을 request body로 전달.
   - `RecommendationsRequest.java`(신규), `QuestionController.java`(`@GetMapping` → `@PostMapping`, `@RequestBody RecommendationsRequest`)
   - `client/src/api/questions.ts`: `fetchRecommendations` POST 방식
2. FIFO 30개 제한: `client/src/pages/Home.tsx`의 `seenUuids`를 최신 30개만 유지(이중 방어).

## 근본 원인 (확정)
`seenUuids`가 세션 내 무제한 누적되어 쿼리스트링 `excludeQuestionUuids`가 약 30회 새로고침 뒤 Tomcat 헤더 한도(8KB)를 넘었다. 400이 CORS 헤더 없이 반환되어 브라우저에선 CORS 에러로 보였다.

## 재발 방지
URL 길이 제한 문제를 POST 본문 전달로 근본 해결하고, 클라이언트 쪽에서도 목록 상한(30개)을 둔다. 이후 앱도 같은 POST 방식으로 맞췄다(GitHub #328).

## 교훈
(원본에 없음, 볼트 정리) 브라우저에 CORS 에러가 보여도 서버 로그에서 400·헤더 한도 예외를 먼저 확인한다. 누적되는 목록은 쿼리스트링으로 보내지 않는다.
