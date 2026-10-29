---
type: decision
id: DEC-0141
created: 2026-10-16
reviewed: null
topics: [question-bank, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0313-sqld-2026-trend-curated-choices]]", "[[ISS-0313-sqld-2026-trend-curated-choices-report]]", "[[DEC-0087-choice-generation-practice-real-mode]]"]
---

# DEC-0141: Oracle 전용 문법 문제는 로컬 Oracle에서 검증한 고정 보기(`CURATED_ONLY`)를 실전·연습 모두 그대로 출제한다

## 문제 정의 (Context)
Oracle 전용 문법 문제는 샌드박스에서 검증되지 않아 개념형이 되고, 실전 모드에서 AI가 매번 보기를 새로 만들어 계산형 정답이 틀어졌다(`8eefc3e3`: AI 보기 정답 3, 실제 2) (GitHub #511).

## 결정 (Decision)
- 문제 정책 `CURATED_ONLY`: 관리자가 검증한 4개 보기(`ADMIN_SEED`·`ADMIN_CURATED`)를 실전·연습 모드 모두 그대로 출제한다. AI 보기 생성·프리페치를 하지 않는다. 고정 세트가 없으면 기존 AI 경로로 대체하고 warn 로그를 남긴다.
- 풀이 응답에서만 보기 순서를 섞고 순번을 다시 매긴다. 채점은 `choiceKey` 그대로.
- 보기는 로컬 Oracle 검증 하네스(`tools/sqld-question-harness/`)에서 정답·오답 기대값을 통과한 것만 JSON 가져오기로 등록한다. 관리자 직접 등록에서는 `CURATED_ONLY`를 막는다.
- 고정 세트의 해설은 검증 근거를 저장하고 AI로 다시 만들지 않는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 운영 신규 37문항이 하네스 검증 통과분으로 들어갔고, 정답 표시 오류·정답 2개 문제가 하네스에서 걸러졌다.

**부정**
- 운영 샌드박스가 PostgreSQL이라 하네스 출력은 `CONCEPT_ONLY` + `CURATED_ONLY`로 나간다.
- 앱이 보기 라벨을 `choiceKey`로 그려 순서를 섞으면 C, A, D, B처럼 보였다(GitHub #512에서 해결).

## 영향 범위 (Scope)
서버 `ChoiceSetResolver`, `ChoiceOrderShuffler`, `QuestionService`, `PrefetchService`, `CuratedChoiceSetWriter`, `ChoiceExplanationService`, `CuratedChoiceValidator`, 관리자 가져오기·등록 화면, `tools/sqld-question-harness/`. 실전 모드를 "항상 AI 실시간 생성"으로 정한 기존 결정(DEC-0087)과 범위가 겹친다.

## 출처 (References)
- GitHub #511 이슈 본문, 보고 댓글 (2026-10-16, 2026-10-17)
- [[ISS-0313-sqld-2026-trend-curated-choices]]
