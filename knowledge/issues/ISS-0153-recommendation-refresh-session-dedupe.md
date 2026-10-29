---
type: issue
id: ISS-0153
created: 2026-04-24
topics: [home, ai]
symptoms: ["추천 새로고침 같은 문제", "동일 Top-K", excludeQuestionUuids, excludeQuestionUuid, seenUuids, mustNotIds]
root_cause: "Qdrant 검색은 같은 쿼리 벡터(오답 패턴)에서 항상 같은 Top-K를 반환해 새로고침해도 같은 문제가 나옴"
status: resolved
resolution: "[[ISS-0153-recommendation-refresh-session-dedupe-report]]"
related: ["[[DEC-0083-session-scoped-recommendation-exclusion]]"]
source: "https://github.com/Twin-Fang/passQL/issues/284"
---

# ISS-0153: 홈 AI 추천 새로고침을 눌러도 같은 문제가 나옴

GitHub #284 (원본: 이슈 본문과 구현 완료 리포트). 라벨은 `작업전`이지만 닫힘 상태와 완료 리포트가 있다.

## 증상
홈 AI 추천 새로고침 버튼을 눌러도 매번 동일한 문제가 반환된다. 버튼의 UX 목적("다른 문제 보고 싶다")과 동작이 어긋난다.

## 재현 조건
오답 기록이 있는 사용자로 홈 추천 새로고침 반복.

## 조사 기록
- 2026-04-24: Qdrant 벡터 검색은 같은 쿼리 벡터에서 항상 같은 Top-K를 반환한다.

## 근본 원인
추천 요청에 이번 세션에서 이미 본 문제를 제외하는 수단이 없었다(제외 파라미터가 단수 `excludeQuestionUuid`).
