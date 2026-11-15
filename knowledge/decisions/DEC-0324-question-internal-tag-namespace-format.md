---
type: decision
id: DEC-0324
created: 2026-11-16
reviewed: null
topics: [question-bank, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0526-question-internal-tags]]", "[[ISS-0526-question-internal-tags-report]]", "[[DEC-0038-question-json-roundtrip-format]]"]
---

# DEC-0324: 문제 내부 관리 태그는 별도 테이블의 소문자 `네임스페이스:값` 문자열(source·round·trend·batch·concept + 자유 태그)이고, 규칙은 `QuestionInternalTagRule` 한 곳

## 문제 정의 (Context)
문제 YAML의 출제 유형·근거 회차·개념이 운영 DB에 들어가면 사라져, 관리자 화면에서 출처를 추적할 수 없었다 (GitHub #1117).

## 결정 (Decision)
- 저장: 새 테이블 `question_internal_tag`(문제·태그 쌍 1행). 개념 학습용 `question_concept_tag`와 분리. 사용자 API(`/api/**`) 미노출, 관리자 전용.
- 형식: 소문자 `네임스페이스:값`. 네임스페이스 5개 `source:{회차}-{문항}`(파생 출처), `round:{회차}`, `trend:{템플릿}`(예 `trend:t41`), `batch:{묶음}`, `concept:{개념}`(한글 허용) + 네임스페이스 없는 자유 태그(예 `new-type`).
- 규칙: 앞뒤 공백 제거, 영문만 소문자(화면은 대문자 표시), 최대 64자, 공백·`*`·쉼표 금지, 네임스페이스나 값이 빈 태그 금지, 문제당 최대 20개. 필터는 끝 `*`면 앞부분 일치(`source:63-*`).
- 규칙 단일 지점 `QuestionInternalTagRule`(가져오기, 1건 교체, 일괄, 필터가 모두 거침). 하네스 `internal_tags.py`가 같은 규칙으로 태그를 만든다.

## 검토한 대안 (Alternatives)
- 기존 `question_concept_tag` 재사용: 이슈 본문 — 개념 사전(`concept_tag`) 연결 용도로 이미 쓰여 자유 형식 관리 태그에 맞지 않음.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 출처 회차·문항, 유형, 묶음별로 관리자 필터·요약·일괄 수정 가능. 운영 요약(2026-11-16): source 73종, trend 51종, round 6종, batch 8종, concept 513종.

**부정**
- 서버 규칙과 하네스 규칙이 사본 관계라 함께 고쳐야 한다(리포트 주의사항).
- 그 밖: 논의 기록 없음.

## 영향 범위 (Scope)
`server/PQL-Domain-Question`(`QuestionInternalTagRule`, `QuestionInternalTagNamespace`, `QuestionInternalTagService`, `QuestionInternalTag`), `V1_136_0__question_internal_tag.sql`, `AdminQuestionInternalTagController`, 관리자 `questions.html`·`question-detail.html`·`question-internal-tags.js`, `tools/sqld-question-harness/sqld_harness/internal_tags.py`.

## 출처 (References)
- GitHub #1117 이슈 본문 「해결 방안」, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1117#issuecomment-6903013598
