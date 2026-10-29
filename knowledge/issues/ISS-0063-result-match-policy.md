---
type: issue
id: ISS-0063
created: 2026-04-11
topics: [question-bank, practice, ai]
symptoms: [RESULT_MATCH, "실행 결과로 올바른 것은?", "결과 테이블 선택지", ChoiceKind.TEXT, ChoiceSetPolicy, "실행 결과 예측 유형 없음"]
root_cause: "AI_ONLY 재정의(#108) 후 SQLD 핵심 유형인 '실행 결과로 올바른 것은?'을 담을 정책이 없었다"
status: resolved
resolution: "[[ISS-0063-result-match-policy-report]]"
related: ["[[DEC-0050-result-match-text-choices]]", "[[ISS-0062-ai-only-choices-mismatch-question-type]]"]
source: "https://github.com/Twin-Fang/passQL/issues/110"
---

# ISS-0063: "실행 결과로 올바른 것은?" 유형을 위한 `RESULT_MATCH` 정책 부재

GitHub #110 (원본: 이슈 본문과 댓글).

## 증상
`AI_ONLY`가 "동일한 결과를 내는 SQL" 유형으로 바뀐 뒤(#108), SQLD 시험의 핵심 유형인 "다음 SQL의 실행 결과로 올바른 것은?"이 없다. 이 유형은 선택지가 SQL이 아니라 실행 결과 테이블이어야 하고, 사용자가 SQL을 머릿속으로 실행해 결과를 예측하는 것이 학습 목표다.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-11: 이슈 본문이 구현 계획(백엔드 5개, 프론트 3개 항목)을 정리.
- 2026-04-11: "적용 완료 / 테스트 미확인" 댓글.

## 근본 원인
정책 미정의.
