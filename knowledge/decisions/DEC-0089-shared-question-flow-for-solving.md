---
type: decision
id: DEC-0089
created: 2026-10-02
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0177-app-daily-set-result-leaderboard]]", "[[ISS-0177-app-daily-set-result-leaderboard-report]]"]
---

# DEC-0089: 앱 풀이 화면은 하나로 두고, 풀이 방식마다 `QuestionFlow`만 구현한다

## 문제 정의 (Context)
앱에 데일리 세트 풀이를 추가하면서 기존 토픽 챕터 풀이와 같은 화면이 필요했다 (GitHub #332).

## 결정 (Decision)
`QuestionFlow`를 추가한다. 풀이 화면은 하나로 두고, 흐름마다 "문제 목록을 가져오는 방법"과 "끝난 뒤 처리"만 구현한다. 토픽 챕터(`TopicFlow`)와 데일리 세트(`DailySetFlow`)가 사용하며, "모의고사, 복습 등 새 풀이 방식은 이 클래스만 구현하면 같은 화면을 쓴다"(원본).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 새 풀이 방식을 추가할 때 화면을 다시 만들지 않는다(원본).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Flutter 앱 풀이 화면, `QuestionFlow`, `TopicFlow`, `DailySetFlow`.

## 출처 (References)
- GitHub #332 구현 댓글(2026-10-02) "구조 변경 (공통화)"
