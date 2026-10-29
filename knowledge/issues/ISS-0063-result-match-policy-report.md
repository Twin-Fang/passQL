---
type: completion-report
id: ISS-0063
created: 2026-04-11
topics: [question-bank, practice, ai]
status: resolved
resolves: "[[ISS-0063-result-match-policy]]"
related: ["[[DEC-0050-result-match-text-choices]]"]
source: "https://github.com/Twin-Fang/passQL/issues/110"
---

# ISS-0063 완료 리포트: `RESULT_MATCH` 적용 완료 (테스트 미확인)

GitHub #110 댓글 "적용 완료 / 테스트 미확인"(2026-04-11) 기준. `## 개요` 형식 리포트는 없다.

## 해결 방법
완료 댓글에는 세부가 없다. 이슈 본문의 작업 계획: `ChoiceSetPolicy.RESULT_MATCH`, `generate_choice_set_result_match` 프롬프트 마이그레이션, `ChoiceSetGenerationService` 분기(answerSql 실행 후 AI 호출), `SandboxValidator` RESULT_MATCH 검증(JSON body vs answerSql 결과 비교), `ChoiceSetSaveService`에서 `kind = TEXT` 저장, 프론트 `ChoiceCard` 컴팩트 결과 테이블·실행 버튼 제거, 가이드 MD 2개. 어디까지 적용됐는지는 원본에 적혀 있지 않다. 프론트 렌더링은 GitHub #112 작업 댓글에 `ResultMatchTable`로 기록돼 있다.

## 근본 원인 (확정)
정책 미정의.

## 재발 방지
원본에 적혀 있지 않다. 완료 댓글이 "테스트 미확인"이라고 적었다.

## 교훈
논의 기록 없음.
