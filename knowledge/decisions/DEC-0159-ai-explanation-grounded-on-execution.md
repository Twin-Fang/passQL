---
type: decision
id: DEC-0159
created: 2026-10-21
reviewed: null
topics: [ai, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0343-daily-set-question-quality-audit]]", "[[ISS-0343-daily-set-question-quality-audit-report]]"]
---

# DEC-0159: AI 해설은 실행형 SQL 보기를 샌드박스에서 실행한 실측 결과를 근거로 쓴다

## 문제 정의 (Context)
오늘의 세트 3번 AI 해설이 입력에만 있는 "기준 SQL"을 언급하고 실제 2행인 결과를 1행이라 서술했다 (GitHub #555).

## 결정 (Decision)
- 해설 생성 시 실행형 SQL 보기를 임시 샌드박스에서 실행해 보기별 실측(행 수, 열, 값, NULL)을 프롬프트의 보기 아래에 넣는다 (`ChoiceSetExecutionEvidenceCollector`).
- 프롬프트 규칙: 실측이 있으면 그 값만, 없으면 샘플 데이터로 따진 값만 쓴다. 내부 자료 이름(기준 SQL, 생성 근거)은 금지하고 검증기가 위반이면 재생성한다.
- 실측 수집이 실패해도 해설 생성은 근거 없이 계속한다.
- `PROMPT_VERSION` 1 > 2로 올려 저장된 해설을 조회 시점에 백그라운드로 다시 만든다.

## 검토한 대안 (Alternatives)
논의 기록 없음. 리포트가 밝힌 근거: "해설 사실 오류의 원인은 모델이 결과를 머릿속으로 추론했기 때문이다. 실측을 넣으면 '결과가 몇 행인지'는 추론이 아니라 입력 사실이 된다."

## 결과 (Consequences)
**긍정**
- 운영 실측에서 재생성 6세트 위반 0, '기준 SQL' 미언급.

**부정**
- 버전 상향 직후 조회량만큼 Gemini 호출과 샌드박스 실행이 일시적으로 는다.
- 해설 프롬프트 리소스는 서버·해설 하네스 공통이라 문구를 바꾸면 버전을 올리고 하네스를 다시 돌려야 한다.

## 영향 범위 (Scope)
`ChoiceSetExecutionEvidenceCollector.java`, `ChoiceSetExplanationPrompt.java`, `ChoiceSetExplanationGenerator.java`, `ChoiceSetExplanationValidator.java`, `ChoiceExplanationService.java`, `ai-prompts/choice-set-explanation/system-instruction.md`. 고정 보기 세트(CURATED_ONLY)는 대상 아님.

## 출처 (References)
- GitHub #555 처리 내용·리포트·배포 실측 댓글(2026-10-21)
- 관련 기존 결정: DEC-0100(해설 프롬프트 맥락을 서버가 넣음)
- [[ISS-0343-daily-set-question-quality-audit]]
