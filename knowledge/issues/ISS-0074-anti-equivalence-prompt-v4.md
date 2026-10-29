---
type: issue
id: ISS-0074
created: 2026-04-11
topics: [ai]
symptoms: [CHOICE_SET_VALIDATION_MULTIPLE_CORRECT, "동치 SQL", "Non EQUI Self Join", "Running Total", generate_choice_set, "프롬프트 v3", "선택지 미표시"]
root_cause: "v3 프롬프트에 '오답은 결과가 달라야 한다'는 추상 규칙만 있고 구체적 동치 패턴 예시가 없어 AI가 문법만 다른 동치 SQL을 오답으로 반복 생성"
status: resolved
resolution: "[[ISS-0074-anti-equivalence-prompt-v4-report]]"
related: ["[[DEC-0055-multiple-correct-ai-fallback-save]]", "[[ISS-0066-ai-only-equivalent-sql-multiple-correct]]"]
source: "https://github.com/Twin-Fang/passQL/issues/126"
---

# ISS-0074: generate_choice_set 동치 SQL 패턴 금지 프롬프트 개선

GitHub #126 (원본: 이슈 본문과 리포트 댓글).

## 증상
`executionMode=EXECUTABLE`, `choiceSetPolicy=AI_ONLY` 문제에서 `CHOICE_SET_VALIDATION_MULTIPLE_CORRECT`가 반복된다. Non EQUI Self Join(Running Total)처럼 동치 표현이 많은 문제에서 AI가 `INNER JOIN` → `JOIN`, `B.SALARY <= A.SALARY` → `A.SALARY >= B.SALARY`, `GROUP BY A.ID, A.NAME` → `GROUP BY A.NAME` 같은 동치 SQL을 오답으로 만든다. 3회 재시도 후에도 실패하면 선택지가 표시되지 않는다.

## 재현 조건
동치 표현이 많은 EXECUTABLE + AI_ONLY 문제의 선택지 생성.

## 조사 기록
- 2026-04-11: 이슈 본문이 v4 프롬프트(동치 패턴 예시·금지 규칙, "오답 작성 전 기준 SQL과 같은 결과를 낼 가능성 점검" 지시)를 제안, `V0_0_73` 마이그레이션 추가 완료로 기록.

## 근본 원인
v3 프롬프트에 구체적인 동치 패턴 예시가 없었다.
