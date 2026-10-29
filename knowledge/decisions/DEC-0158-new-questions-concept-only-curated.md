---
type: decision
id: DEC-0158
created: 2026-10-20
reviewed: null
topics: [question-bank, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0336-sqld-2026-trend-question-pool-refresh]]", "[[ISS-0336-sqld-2026-trend-question-pool-refresh-report]]", "[[DEC-0087-choice-generation-practice-real-mode]]"]
---

# DEC-0158: 2026 경향 신규 문제는 `CONCEPT_ONLY` + `CURATED_ONLY`(고정 보기)로 등록한다

## 문제 정의 (Context)
GitHub #548에서 58~62회 경향 기준 신규 문제 143개를 등록하면서 실행 모드와 보기 출처를 정해야 했다.

## 결정 (Decision)
신규 문제는 모두 `CONCEPT_ONLY` + `CURATED_ONLY`(고정 보기)로 등록한다. 기존 수정본 32건도 고정 보기로 전환했다. 정답은 검증 도구의 Oracle 실행 결과로 판정한다.

## 검토한 대안 (Alternatives)
리포트가 적은 이유: "운영 샌드박스는 PostgreSQL이라 Oracle 문법 결과가 다르고, AI 즉석 보기는 계산형 문제에서 오답을 만든다." 그 밖의 대안 비교는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 정답이 Oracle 실행으로 검증된 고정 보기라 계산형 문제의 AI 오답 보기를 피한다(리포트 서술 기준).

**부정**
- 같은 UUID로 다시 가져오면 고정 보기 세트가 통째로 교체된다(리포트 주의사항). 그 밖은 논의 기록 없음.

## 영향 범위 (Scope)
문제 가져오기(`/admin/questions/import`, `/admin/questions/bulk`), 반영 후 활성 309건 중 보기 고정 212건.

## 출처 (References)
- GitHub #548 리포트 댓글(2026-10-20)
- [[ISS-0336-sqld-2026-trend-question-pool-refresh]]
