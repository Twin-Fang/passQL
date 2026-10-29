---
type: issue
id: ISS-0173
created: 2026-10-02
topics: [dev-workflow, auth-member]
symptoms: ["memberUuid 쿼리/헤더", "추천 문제 GET", sessionUuid, Retrofit, "/questions/today 제거", "API 계약 불일치", XApiClient]
root_cause: "앱 API 정의가 구버전 서버 기준이라 현재 서버(JWT 식별, 추천 POST 등)와 맞지 않음"
status: resolved
resolution: "[[ISS-0173-app-api-client-server-alignment-report]]"
related: ["[[DEC-0084-recommendation-exclusion-post-body-fifo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/328"
---

# ISS-0173: 앱 API 클라이언트 서버 현행화 (memberUuid 제거, 추천 POST)

GitHub #328 (원본: 이슈 본문과 완료 댓글). 선행 GitHub #327.

## 증상
(현재 문제점) 여러 API에서 `memberUuid` 쿼리/헤더를 직접 넘긴다. 추천 문제를 앱은 GET, 웹은 POST(`size`, `excludeQuestionUuids`)로 쓴다(웹 쪽 이유는 GitHub #291 헤더 한도 초과 400). 진도 AI 코멘트 파라미터명이 서버(`sessionUuid`)와 맞는지 확인 필요.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02: 작업 중 서버에서 `/questions/today`가 제거되고 `/daily-set/today`로 대체된 것을 발견 — 앱 홈 오늘의 문제 카드는 항상 비어 있음(GitHub #332에서 교체).

## 근본 원인
앱 API 정의가 서버 변경을 따라가지 못했다.
