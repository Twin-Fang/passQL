---
type: decision
id: DEC-0194
created: 2026-10-28
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0417-sequential-execution-explanation-errors]]", "[[ISS-0417-sequential-execution-explanation-errors-report]]"]
---

# DEC-0194: 선택지 세트 해설은 보이지 않는 풀이 메모(`workingNotes`)를 먼저 쓰게 하고, 근거 우선순위는 실행 결과 > 고정 세트 검증된 풀이 > 생성 근거 > 자체 계산

## 문제 정의 (Context)
차례 실행·개수 세기 문제에서 해설 정답 근거가 틀리거나 결론 없이 끝났다. 관리자 메모에는 올바른 계산이 있었지만 "생성 근거(참고)"로만 들어가 모델이 따르지 않아도 됐다 (GitHub #716).

## 결정 (Decision)
- 응답 스키마 맨 앞에 `workingNotes`(풀이 메모)를 둔다. 파싱 때 버려 저장·노출하지 않는다.
- 근거 우선순위: 실행 결과 > 검증된 풀이(Oracle 실행 확인) > 생성 근거(참고) > 자체 계산. 자체 계산이 다르면 고쳐 쓰고 차이는 해설에 남기지 않는다.
- 고정(관리자) 세트 메모는 `검증된 풀이(Oracle 실행 확인)`, AI 세트 메모는 `생성 근거(참고)` 라벨로 전달.
- 저장 전 검증: 결론 미루는 표현, 숫자 답인데 근거에 숫자 없음, 입력 자료·작성 과정 언급, 내부 이름 금지. 위반이면 1회 재시도, 그래도 위반이면 저장 안 함.

## 검토한 대안 (Alternatives)
- 사고 과정(thinking) 켜기: Claude 강제 도구 호출은 thinking과 함께 쓸 수 없어, 사고 과정을 켜지 않고 따져 볼 자리를 만드는 방식을 택함(리포트).
- 그 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 재생성 대조에서 같은 유형 54개 중 53개, 2차 후 9세트 모두 메모와 일치.

**부정**
- 세트당 출력 토큰 수백 증가.
- 고정 세트 메모가 틀리면 해설도 틀린다.
- 중간 나열 오류, 숫자가 아닌 답의 계산 오류는 자동 검증 대상이 아니다.

## 영향 범위 (Scope)
`ai-prompts/choice-set-explanation/`, `ChoiceSetExplanationPrompt`, `ChoiceSetExplanationGenerator`, `ChoiceExplanationService.generateAndStore`, `ChoiceSetExplanationValidator`.

## 출처 (References)
- GitHub #716 이슈 본문 「해결 방안」, 리포트 댓글 (2026-10-28)
- [[ISS-0417-sequential-execution-explanation-errors]]
