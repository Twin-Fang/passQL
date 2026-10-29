---
type: decision
id: DEC-0195
created: 2026-10-28
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0417-sequential-execution-explanation-errors]]", "[[ISS-0417-sequential-execution-explanation-errors-report]]"]
---

# DEC-0195: 해설 일부만 다시 만들 때는 프롬프트 버전을 올리지 않고 대상 세트만 `explanation_prompt_version`을 낮춰 백필이 재생성하게 한다

## 문제 정의 (Context)
프롬프트를 고친 뒤 차례 실행·개수 유형 세트만 다시 만들어야 했다. 프롬프트 버전을 올리면 공용 세트 전체(약 270세트)가 다시 생성된다 (GitHub #716).

## 결정 (Decision)
- 프롬프트 버전은 그대로(2) 둔다.
- 대상 세트만 `explanation_prompt_version = 1`로 낡은 표시를 해 백필이 다시 만들게 한다.
- 리포트: "다음에 같은 방식으로 일부만 재생성할 때도 이 방법을 쓴다."
- 자동 재생성 범위 밖 AI 세트는 낡은 버전으로 표시해 두어 문제를 열 때 새 프롬프트로 다시 생성되게 한다(2차 실측 댓글).

## 검토한 대안 (Alternatives)
- 프롬프트 버전 올리기: 공용 세트 전체 재생성을 피하려고 택하지 않음(이슈 본문·리포트).

## 결과 (Consequences)
**긍정**
- 필요한 세트만 재생성해 호출·비용을 줄인다.

**부정**
- 백필은 고정 세트와 문제별 최신 AI 세트만 다시 만든다. 그 밖의 AI 세트는 누군가 문제를 열 때 다시 만들어진다.

## 영향 범위 (Scope)
`explanation_prompt_version` 컬럼, 해설 백필, `ChoiceSetExplanationPrompt.PROMPT_VERSION` 운용.

## 출처 (References)
- GitHub #716 리포트 「주의 사항」, 2차 배포 후 재생성 실측 댓글
- [[ISS-0417-sequential-execution-explanation-errors]]
