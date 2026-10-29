---
type: issue
id: ISS-0213
created: 2026-10-07
topics: [practice]
symptoms: ["0개 서브토픽", TopicCard, subtopics 빈 배열, "GET /api/meta/topics"]
root_cause: "서버가 모든 토픽의 `subtopics`를 `[]`로 내려주는데 `TopicCard`가 개수 0도 그대로 표시했다"
status: resolved
resolution: "[[ISS-0213-topic-card-zero-subtopics-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/368"
---

# ISS-0213: 문제 탭 토픽 카드마다 "0개 서브토픽"이 표시됨

GitHub #368 (원본: 이슈 본문과 댓글).

## 증상
문제 탭의 토픽 카드 9개 모두 "0개 서브토픽"이 표시된다. 사용자에게 의미 없는 문구.

## 재현 조건
QA GitHub #357 영역 4(iPhone 16 Pro, 실계정): 문제 탭. API `GET /api/meta/topics` 응답의 `subtopics`가 전부 `[]`.

## 조사 기록
- 2026-10-07: 서버 응답 확인, 데이터 쪽 변경은 하지 않음.

## 근본 원인
개수 0일 때 문구를 숨기는 처리가 없었다. 서버가 왜 모든 `subtopics`를 빈 배열로 주는지는 원본에 적혀 있지 않다.
