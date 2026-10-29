---
type: decision
id: DEC-0100
created: 2026-10-07
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0201-ai-explain-model-compare-prompt]]", "[[ISS-0201-ai-explain-model-compare-prompt-report]]", "[[DEC-0099-explain-model-gemini-3-5-flash-lite]]"]
---

# DEC-0100: AI 해설 프롬프트에 규칙·샘플 데이터·전체 선택지를 서버(`AiExplainService`)가 넣는다

## 문제 정의 (Context)
모델 비교 1차(기존 프롬프트 v1)에서 SQL형은 세 모델 모두 애매했고, 개념형 "옳지 않은 것"을 틀리거나 무관한 주제를 덧붙였다. 원본이 적은 원인: v1 프롬프트에 샘플 데이터·전체 선택지가 없고, 시스템 프롬프트가 UNION/JOIN 같은 다른 주제를 유도했다 (GitHub #356).

## 결정 (Decision)
"프롬프트 보완이 품질을 가장 크게 올렸다 → 서버 코드(`AiExplainService`)에 규칙·샘플 데이터·전체 선택지를 넣는다." 보완 항목: 샘플 데이터, 전체 선택지, '옳지 않은 것' 규칙, LaTeX 금지.

## 검토한 대안 (Alternatives)
- 기존 v1 프롬프트 유지: 1차 실험 결과로 탈락(위 문제 정의).
- 그 밖의 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 2차 실험에서 SQL형이 세 모델 모두 "애매" → "정확"으로 바뀌었다.

**부정**
- 입력 토큰 증가: 결과표형 659 → 1089, SQL형 351 → 569, 개념형 251 → 426.

## 영향 범위 (Scope)
서버 `AiExplainService`, 운영 프롬프트 `diff_explain`·`explain_error` v2(Flyway `V0_0_228`).

## 출처 (References)
- GitHub #356 이슈 본문 「1차 결과」 원인 문장, 「2차 결과」, 「결정」
