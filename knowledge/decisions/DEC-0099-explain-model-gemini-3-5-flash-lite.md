---
type: decision
id: DEC-0099
created: 2026-10-07
reviewed: null
topics: [ai]
status: archived
supersedes: null
superseded_by: null
related: ["[[ISS-0201-ai-explain-model-compare-prompt]]", "[[ISS-0201-ai-explain-model-compare-prompt-report]]", "[[DEC-0100-explain-prompt-context-in-server]]", "[[ISS-0208-concept-choice-prompt-v2-quality]]"]
---

# DEC-0099: AI 해설 모델은 lite 3종 중 `gemini-3.5-flash-lite`

## 문제 정의 (Context)
AI 해설(GitHub #354)을 구현하면서 모델을 정해야 했다. 사용자 요청: 비싼 모델은 쓰지 않고 하위 등급 모델 3개 안에서 비교해 고른다 (GitHub #356).

## 결정 (Decision)
- 해설 모델은 3종 중 오류가 가장 적은 `gemini-3.5-flash-lite`.
- Flyway `V0_0_228`로 해설 프롬프트 v2(temperature 0.3, max 1024)를 넣고 v1은 비활성. 관리자 화면에서 모델을 바로 바꿀 수 있다.

## 검토한 대안 (Alternatives)
- `gemini-2.5-flash-lite`(기존): 1차에서 개념형 "옳지 않은 것"을 틀림, 2차에서도 개념형 사실 오류 1건.
- `gemini-3.1-flash-lite`: 1차에서 무관한 팁 덧붙임, 2차에서 결과표형 오답 원인을 잘못 짚음.
- 상위 등급(비싼) 모델: 사용자 요청으로 비교 대상에서 제외.

## 결과 (Consequences)
**긍정**
- 2차 실험에서 3문제 모두 정확(표현 일부 부정확).

**부정 / 조건**
- 단가는 확인하지 않았다(토큰 수만 측정). 원본: "3.5-flash-lite 가 비용 면에서 부담되면 2.5-flash-lite + 보완 프롬프트로 내려도 대부분 정확하다."
- (원본에 없음, 볼트 정리) 실험 표본은 문제 3개(유형별 1개)였다.

## 영향 범위 (Scope)
운영 프롬프트 `diff_explain`·`explain_error`의 모델 설정(Flyway `V0_0_228`), 관리자 프롬프트 관리 화면. 이후 GitHub #363이 개념 선택지 생성 프롬프트에도 "#356 비교 결과의 gemini-3.5-flash-lite"를 썼다.
(원본 기록) 기존 볼트 결정 DEC-0029는 AI 서버 호출 모델을 `gemini-2.5-flash-lite`로 적었다. #356은 해설 프롬프트의 모델을 바꾼다고만 했고 DEC-0029를 대체한다고 명시하지 않았다.

## 출처 (References)
- GitHub #356 이슈 본문 「실험 방법」「1차·2차 결과」「결정」, 검증 댓글(2026-10-08)
