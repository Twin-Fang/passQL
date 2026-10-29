---
type: issue
id: ISS-0419
created: 2026-10-27
topics: [ai, question-bank]
symptoms: ["일반 SQL 선택지 생성 성공률 낮음", AI_ONLY, "정답 2~4개 채점", "오답이 기준 SQL과 같은 결과", "ELSE 0", ">= 를 > 로", "상관 서브쿼리", "CASE PIVOT"]
root_cause: "AI가 기준 SQL 실행 결과를 직접 계산하다 틀려 샘플 데이터에서 결과가 같은 SQL을 오답으로 넣었고, 재시도 피드백은 동치 SQL 목록만 줬다"
status: resolved
resolution: "[[ISS-0419-ai-only-choice-answer-result-feedback-report]]"
related: ["[[DEC-0197-provide-answer-sql-result-in-prompt]]", "[[ISS-0418-gemini-fallback-model-3-1-flash-lite]]"]
source: "https://github.com/Twin-Fang/passQL/issues/720"
---

# ISS-0419: 일반 SQL 선택지 생성 — 기준 실행 결과 제공, 재시도 실행 결과 피드백

GitHub #720 (원본: 이슈 본문과 댓글).

## 증상
일반 SQL(AI_ONLY, "다음 SQL과 같은 결과를 내는 SQL은?") 선택지 생성에서 Haiku 성공률 46~67%(GitHub #719 측정). 상관 서브쿼리, CASE PIVOT 두 문제는 매번 3회 시도 모두 실패. 오답이 샘플 데이터에서 기준 SQL과 같은 결과를 내 정답이 2~4개로 채점된다:
- 기준 SQL을 그대로 오답 보기로 넣음
- `SUM(CASE ... ELSE 0 END)`에서 `ELSE 0`만 뺌(NULL이 없으면 결과 같음)
- `>=`를 `>`로(경계값 행이 없으면 같음)
- 상관 조건 `A.CATEGORY_ID` → `B.CATEGORY_ID`(조인 키라 같음)

## 재현 조건
`claude-haiku-5-5`로 AI_ONLY 문제 선택지 생성.

## 조사 기록
- 비교(운영 일반 SQL 6문제 x 4회 = 24건, 운영 채점 규칙): `claude-haiku-5-5` v5 46%(11/24) → v6 96%(23/24), `gemini-3.1-flash-lite` 96% → 96%. 두 문제 0/4 → 4/4, 0/4 → 3/4.

## 근본 원인
AI의 기준 SQL 결과 직접 계산 오류와 결과를 알려 주지 않는 재시도 피드백.
