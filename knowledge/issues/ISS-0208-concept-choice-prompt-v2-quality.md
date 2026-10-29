---
type: issue
id: ISS-0208
created: 2026-10-07
topics: [ai, question-bank]
symptoms: [개념 선택지 변별력 낮음, 정답 근거 약함, generate_choice_set_concept, "'옳지 않은 것' 방향 규칙", 프롬프트 v1 규칙 5줄]
root_cause: "개념 선택지 생성 프롬프트(v1)가 규칙 5줄뿐이라 '옳지 않은 것' 방향 규칙·부분집합 금지·오개념 기준·자기 검증이 없었다"
status: resolved
resolution: "[[ISS-0208-concept-choice-prompt-v2-quality-report]]"
related: ["[[DEC-0099-explain-model-gemini-3-5-flash-lite]]", "[[ISS-0202-top-level-qa-real-account-e2e]]"]
source: "https://github.com/Twin-Fang/passQL/issues/363"
---

# ISS-0208: 개념 문제 AI 선택지 품질 개선 — 정확하고 변별력 있게

GitHub #363 (원본: 이슈 본문과 댓글).

## 증상
QA GitHub #357 영역 3·4: 개념 문제 "SQL 명령어 분류로 옳지 않은 것은?"에서 A~D가 모두 그럴듯하고 정답(C) 근거가 약해 보였다.

## 재현 조건
개념(이론) 문제의 AI 선택지 생성.

## 조사 기록
- 2026-10-07: 현재 프롬프트(v1)에 없는 것 — "옳지 않은 것" 문제의 정답(=틀린 설명)·오답(=확실히 옳은 설명) 방향 규칙, 선택지끼리 부분집합·누락 관계 방지, 오답을 흔한 오개념으로 만드는 기준, 생성 후 자기 검증.
- 2026-10-07: v1/v2 비교 — 같은 개념 문제 4개를 NAS에서 직접 호출(v1: `gemini-2.5-flash-lite` 0.7, v2: `gemini-3.5-flash-lite` 0.5). v1은 서브쿼리 문제에서 정답 근거 오류("IN: 하나라도 만족하면 참"은 참), 오답이 밋밋함. v2는 4/4에서 정답 1개, 오답 3개 모두 확실한 사실.

## 근본 원인
v1 프롬프트의 규칙 부족.
