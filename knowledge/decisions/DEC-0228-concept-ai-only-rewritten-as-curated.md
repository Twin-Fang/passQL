---
type: decision
id: DEC-0228
created: 2026-10-31
reviewed: null
topics: [question-bank, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0435-concept-ai-only-49-rewrite-curated]]", "[[ISS-0435-concept-ai-only-49-rewrite-curated-report]]", "[[DEC-0158-new-questions-concept-only-curated]]", "[[DEC-0141-curated-only-oracle-verified-choices]]"]
---

# DEC-0228: `AI_ONLY` 개념 문제 49개는 비활성화하고, 핵심 개념을 상황·결과로 정면으로 묻는 고정 보기(`CURATED_ONLY`) 문제로 다시 쓴다 — 오답은 실제 오개념, 결과형은 Oracle 21c 검증

## 문제 정의 (Context)
운영 개념 문제 261개 중 49개가 `AI_ONLY`라 AI가 범위형 지문 한 줄만 보고 정답·오답을 지어냈고, 정답 키가 틀리거나(PRIOR 위치) 오답이 자기모순이었다 (GitHub #767).

## 결정 (Decision)
- 옛 `AI_ONLY` 개념 문제 49개는 비활성화한다(풀이 기록 보존). 재작성 전까지도 비활성.
- 한 개념(필요하면 두 개)의 핵심을 상황형·결과형으로 정면으로 묻는 문제 49개로 바꾸고, 범위형 지문("X에 대한 설명으로 옳지 않은 것은?")은 남기지 않는다.
- 모두 `CONCEPT_ONLY` + `CURATED_ONLY`, 관리자 고정 세트 1개·보기 4개·정답 1개. 오답 3개는 각각 실제 오개념 하나를 대표하고 `whyPlausible`을 남긴다.
- 결과형(37개)은 Oracle 21c로 정답을 검증하고, 이론형(12개)은 개념 근거 출처를 남긴다.
- 기존 고정 문제 212개와 같은 함정이면 다른 핵심을 고른다.
- 결과: 활성 개념 문제 261개 전부 고정 보기(`AI_ONLY` 0개). [[DEC-0158-new-questions-concept-only-curated]](신규 문제는 `CONCEPT_ONLY` + `CURATED_ONLY`)을 기존 `AI_ONLY` 개념 문제에도 적용한 것이다.

## 검토한 대안 (Alternatives)
- `AI_ONLY` 유지(즉석 AI 보기): 정답 오류·자기모순 오답 때문에 버림(이슈 본문 설명·재현). 그 밖의 대안 비교는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- Oracle 21c verify 49/49, 보기 196개 판정이 모두 맞았다.

**부정**
- 개념 문제 AI 보기 경로는 코드에 남아 있어, 관리자가 `AI_ONLY`로 개념 문제를 새로 등록하면 같은 문제가 다시 생길 수 있다. 등록 화면에서 개념형 + `AI_ONLY` 조합을 막을지는 미결.
- 등록 직후 구조화 해설은 비어 있고 백필 스케줄러가 채운다.

## 영향 범위 (Scope)
운영 개념 문제 데이터(관리자 가져오기), `docs/sqld-research-encrypted/questions/batch06a~e-concept-rewrite-*.yaml.enc`.

## 출처 (References)
- GitHub #767 이슈 본문 「예상 동작」, 리포트 댓글 「개요」·「핵심 구현」·「주의 사항」
- [[ISS-0435-concept-ai-only-49-rewrite-curated-report]]
