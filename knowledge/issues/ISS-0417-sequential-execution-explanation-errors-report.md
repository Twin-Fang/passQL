---
type: completion-report
id: ISS-0417
created: 2026-10-28
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0417-sequential-execution-explanation-errors]]"
related: ["[[DEC-0194-explanation-working-notes-evidence-priority]]", "[[DEC-0195-targeted-regeneration-without-version-bump]]"]
source: "https://github.com/Twin-Fang/passQL/issues/716"
---

# ISS-0417 완료 리포트: 풀이 메모 칸, 근거 우선순위, 결론·숫자·내부 문장 검증

GitHub #716 리포트 댓글과 2차 실측 댓글(2026-10-28) 기준.

## 해결 방법
- 프롬프트(`ai-prompts/choice-set-explanation/`): 응답 스키마 맨 앞에 `workingNotes`(풀이 메모) — 차례 실행·개수 문제는 문장마다 판정 한 줄 + 합계. `ChoiceSetExplanation`에 필드가 없어 파싱 때 버려져 저장·노출 안 함. 근거 우선순위: 실행 결과 > 검증된 풀이(Oracle 실행 확인) > 생성 근거(참고) > 자체 계산. 결론 미루는 표현·입력 자료·작성 과정 언급 금지, 지문 SQL은 '지문의 SQL'. Oracle 예시: 집합 연산자 우선순위 같음, `''` = NULL.
- 서버: `ChoiceSetExplanationPrompt`·`ChoiceSetExplanationGenerator`가 고정 세트 메모는 `검증된 풀이(Oracle 실행 확인)`, AI 세트 메모는 `생성 근거(참고)` 라벨로 전달(`QuestionService.isCuratedChoiceSet`으로 결정). `ChoiceSetExplanationValidator` 위반 추가 — 결론 미루는 표현, 숫자가 답인 보기인데 근거에 그 숫자 없음("4번" 같은 순번 제외), 입력 자료·작성 과정 언급, 내부 이름 '기준 쿼리'·'검증된 풀이'. 위반이면 피드백 붙여 1회 재시도, 그래도 위반이면 저장 안 함.
- 검증: 새 규칙을 저장된 해설 전체에 먼저 적용해 오탐 확인(결론·숫자 202개 중 CTAS 1건, 입력 자료 언급 274개 중 실제 노출 3세트). 1차 배포 후 차례 실행·개수 유형 37세트 중 35세트 재생성, CTAS "1 + 3 = 4행", UNIQUE "7건에서 실패 2건을 뺀 5행". 같은 유형 54개 메모 대조 53개 일치. 2차 배포 후 9세트 모두 메모와 일치. 노출 고정 세트 3개는 2차 배포 전까지 해설을 내리고 메모만 표시.

## 근본 원인 (확정)
결론 우선 응답 형식, 사고 과정 없는 강제 도구 호출, 메모를 따르지 않아도 되는 라벨, 결론·숫자를 보지 않는 검증.

## 재발 방지
- 검증으로 못 막는 오류: 합계는 맞는데 중간 나열이 틀린 경우, 숫자가 아닌 답의 계산 오류.
- 고정 세트 메모가 정답의 기준 — 관리자 문제를 고칠 때 메모도 Oracle 실행 결과와 맞춘다.
- 풀이 메모는 세트당 출력 수백 토큰 증가(세트당 1회 생성·공유라 영향 작음).
- Claude 강제 도구 호출은 thinking과 함께 쓸 수 없다(리포트).

## 교훈
(원본에 없음, 볼트 정리) 구조화 출력에서 결론 필드가 앞에 있으면 모델이 근거 없이 결론부터 쓴다 — 버려지는 작업 칸을 앞에 두고, 결론·숫자 포함 여부를 저장 전에 검사한다.
