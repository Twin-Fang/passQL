---
type: issue
id: ISS-0435
created: 2026-10-31
topics: [question-bank, ai]
symptoms: ["AI_ONLY 개념 문제", "CONCEPT_ONLY + AI_ONLY", "정답 오류", "정답 보기가 생성마다 반대", "PRIOR 위치 전개 방향", "CONNECT BY", "의미 없는 보기", "자기모순 오답", "설명으로 옳지 않은 것은", "범위형 지문", AI_RUNTIME]
root_cause: "개념 문제 49개가 보기 정책 AI_ONLY라 풀 때마다 AI가 범위만 있는 지문 한 줄(\"X에 대한 설명으로 옳지 않은 것은?\")만 보고 정답과 오답을 지어냈다"
status: resolved
resolution: "[[ISS-0435-concept-ai-only-49-rewrite-curated-report]]"
related: ["[[ISS-0435-concept-ai-only-49-rewrite-curated-report]]", "[[DEC-0228-concept-ai-only-rewritten-as-curated]]", "[[DEC-0158-new-questions-concept-only-curated]]", "[[DEC-0141-curated-only-oracle-verified-choices]]", "[[ISS-0208-concept-choice-prompt-v2-quality]]"]
source: "https://github.com/Twin-Fang/passQL/issues/767"
---

# ISS-0435: AI 선택지 개념 문제 49개 — 정답 오류와 의미 없는 보기, 고정 보기 문제로 재작성

GitHub #767 (원본: 이슈 본문과 리포트 댓글).

## 증상
- 운영 개념 문제(`CONCEPT_ONLY`) 261개 중 49개는 보기 정책이 `AI_ONLY`라 풀 때마다 AI가 지문 한 줄만 보고 정답과 오답을 지어낸다. 나머지 212개는 미리 써서 검증한 고정 보기(`CURATED_ONLY`).
- 49개 지문은 모두 "X에 대한 설명으로 옳지 않은 것은?"처럼 범위만 있어 핵심 개념을 묻지 못하고 매번 다른 잡다한 문장이 보기로 나온다.
- 운영 조회(10-30): 최근 14일 개념 문제 보기 세트 `AI_RUNTIME` 25개.

## 재현 조건
1. `AI_ONLY` 개념 문제(예: 계층형 질의에서 `PRIOR` 키워드 위치에 따른 전개 방향)를 푼다.
2. 같은 문제를 두 번 생성하면 정답 보기가 서로 반대다(10-28 생성분 중 하나는 `CONNECT BY 부모컬럼 = PRIOR 자식컬럼`을 역방향이라고 정답 처리).
3. 형변환 문제처럼 오답이 자기모순이라 개념을 몰라도 정답을 고를 수 있다.

## 조사 기록
- 2026-10-30: 이슈 등록(운영 서버 v1.70.9). 재작성 전까지 49개를 관리자 일괄 비활성화(49건).
- 2026-10-30: 주제별 5묶음으로 재작성, 관리자 가져오기로 운영 등록, 원본 암호화본은 PR #768로 병합. 리포트 댓글로 완료 → [[ISS-0435-concept-ai-only-49-rewrite-curated-report]].

## 근본 원인
`AI_ONLY` 보기 정책 + 범위형 지문. AI가 근거 없이 정답·오답을 만들어 정답 키가 틀리거나(PRIOR 위치 문제) 오답이 자기모순이 됐다.
