---
type: completion-report
id: ISS-0414
created: 2026-10-27
topics: [ai, question-bank, practice]
status: resolved
resolves: "[[ISS-0414-odd-one-out-choice-generation-fails]]"
related: ["[[ISS-0416-choice-set-prompts-claude-gemini]]"]
source: "https://github.com/Twin-Fang/passQL/issues/704"
---

# ISS-0414 완료 리포트: ODD_ONE_OUT 유형 지시 덧붙임과 실제 실행 결과 피드백

GitHub #704 리포트 댓글 기준 (커밋 `fb80dfc2`, Spring Blue-Green 배포 성공).

## 해결 방법
- `ChoiceSetGenerationRequestFactory`: `ODD_ONE_OUT` 문제는 사용자 프롬프트 끝에 유형 지시(3개는 기준 SQL과 같은 결과, 1개만 다른 결과이고 그 1개가 정답, 공통 지시보다 우선)를 붙인다. `toOddOneOutResultLines`가 실패 시도의 선택지별 실제 실행 결과를 `A: {SQL} > 결과 …` 형식의 줄로 만든다(원본 예시는 결과 값 30을 이중 대괄호로 감싼 형태 — 볼트 링크와 겹쳐 그대로 옮기지 않음).
- `ChoiceSetGenerationService.generate`: 검증 실패 시 직전 시도의 실제 실행 결과를 다음 시도 프롬프트에 피드백(매 시도 교체). 표준 유형의 동치 SQL 피드백과 같은 방식.
- GitHub #699의 전용 프롬프트 `generate_choice_set_odd_one_out`(`V1_63_2`, `V1_63_3`)와 컬럼 이름 제외 비교 뒤에 그대로 붙어 함께 동작.

## 근본 원인 (확정)
공통 프롬프트 지시와 `validateOddOneOut` 판정 기준이 반대.

## 재발 방지
- 공통 프롬프트(`generate_choice_set`)의 "정답은 기준 SQL과 같은 결과" 문장은 그대로 두고 이 유형만 코드에서 지시를 덧붙이는 구조 — 관리자 화면에서 프롬프트를 고칠 때 우선 지시를 무력화하는 문구를 넣으면 다시 실패할 수 있다.
- 판정은 "결과가 1번만 나온 선택지"를 정답으로 보므로 기준과 같은 결과 1개 + 다른 결과 3개(같은 값)도 통과한다(문제 문구와는 맞음).
- 검증: `:PQL-Web:test` 통과. Haiku 직접 호출 시뮬레이션 4번 모두 3회 안에 통과(실행은 sqlite로 대신). 실측(문제 df77c99a): 수정 전 9회 모두 실패, #699 v2 단독 4회 중 3회, #699 v2 + 이 이슈 지시 4회 중 4회.

## 교훈
(원본에 없음, 볼트 정리) LLM 생성이 검증에서 계속 떨어지면 모델을 의심하기 전에 프롬프트 지시와 검증 기준이 같은 것을 요구하는지부터 대조한다. 한 모델에서 우연히 통과하던 것이 모델 교체로 드러날 수 있다.
