---
type: decision
id: DEC-0137
created: 2026-10-16
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0301-ai-explanation-persist-pregenerate]]"]
---

# DEC-0137: 선택지 해설은 세트 저장 직후 별도 호출로 미리 생성해 DB에 영구 저장하고, 샌드박스 미검증 세트는 제외

## 문제 정의 (Context)
AI 해설이 Redis에 24시간만 캐시되고 버튼을 눌러야 생성돼 매번 기다리고 Gemini를 다시 불렀다 (GitHub #496).

## 결정 (Decision)
- 선택지 세트가 샌드박스 검증을 통과해 저장되면(`ChoiceSetReadyEvent`) 커밋 뒤 비동기로 선택지 A~D 해설을 한 번 더 호출해 만들고 `question_choice_set_item.explanation`에 저장한다. 설계 댓글: 해설 모델과 temperature 0.3, 구조화된 응답 하나.
- 제출 응답(`SubmitResult.explanation`)에 고른 선택지의 저장된 해설을 실어 즉시 보여 준다.
- 저장본이 없으면 첫 요청 때 생성해 저장하고 이후 재사용. 해설 없는 세트는 백필 스케줄러가 채운다.
- 프롬프트 버전(`explanation_prompt_version`)을 함께 저장해, 관리자가 `diff_explain` 프롬프트를 바꾸면 이후 요청·백필에서 다시 만든다.
- SQL 오류 해설은 미리 만들 수 없어 요청 시 생성하고 (문제, 정규화 SQL SHA-256, 오류) 기준으로 DB에 저장해 재사용한다.
- 해설 Redis 캐시는 제거한다.

## 검토한 대안 (Alternatives)
- 선택지 생성과 같은 호출에 해설을 넣는 방식: 버림. 원본 이유 — 선택지 생성은 temperature 0.9에 토큰 1536 안에 선택지 4개를 넣어야 해서 해설이 얕아지고, 샌드박스 검증에 실패한 시도의 해설은 버려진다.
- 샌드박스 미검증 세트(AI 판단 fallback)에도 미리 생성: 제외. 원본 이유 — 틀린 세트에 붙은 해설이 여러 사용자에게 퍼지는 것을 막기 위해.

## 결과 (Consequences)
**긍정**
- PRACTICE 모드는 문제당 최신 OK 세트를 공유하므로 세트당 한 번 생성하면 이후 모든 사용자에게 비용 없이 즉시 보여 줄 수 있다(설계 댓글).

**부정**
- REAL 모드는 세트가 계속 늘어 세트마다 해설 4건을 만든다(비용이 문제가 되면 요청 시 생성만으로 바꾸는 방안이 원본에 적혀 있음).
- 아직 생성되지 않은 세트의 첫 요청자는 기다린다.

## 영향 범위 (Scope)
마이그레이션 `V0_10_50`, `AiExplanationGenerator`, `ChoiceExplanationService`, `ChoiceSetReadyEvent` 리스너, `ChoiceExplanationBackfillScheduler`, `AiExplainService`, `SubmitResult`, 앱 `AiExplainSheet`, 웹 해설 카드·연습 피드백 바.

## 출처 (References)
- GitHub #496 설계 근거 댓글(2026-10-16 09:47), 구현 보고서 댓글 "왜 이 방식인가"
- [[ISS-0301-ai-explanation-persist-pregenerate]]
