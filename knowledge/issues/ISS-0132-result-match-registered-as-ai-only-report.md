---
type: completion-report
id: ISS-0132
created: 2026-04-13
topics: [question-bank, ai]
status: resolved
resolves: "[[ISS-0132-result-match-registered-as-ai-only]]"
related: ["[[DEC-0075-stem-pattern-choice-set-policy-mapping]]"]
source: "https://github.com/Twin-Fang/passQL/issues/242"
---

# ISS-0132 완료 리포트: 가이드 문서·AI 변환 프롬프트의 정책-stem 매핑 정정

GitHub #242 `## 개요` 리포트 댓글(2026-04-13) 기준.

## 해결 방법
- `server/PQL-Web/src/main/resources/static/docs/question-single-guide.md`, `question-bulk-guide.md`: JSON 예시 수정(`AI_ONLY` + "동일한 실행 결과를 내는 SQL은?"), choiceSetPolicy 선택 기준 표에 `RESULT_MATCH` 행과 "선택지 형태" 컬럼 추가, 체크리스트에 세 stem 패턴 명시.
- 두 파일 하단 AI 변환 프롬프트에서 `AI_ONLY` 설명 정정, `RESULT_MATCH` 항목 추가.

## 근본 원인 (확정)
가이드 문서와 프롬프트의 정책-stem 패턴 혼동.

## 재발 방지
리포트 주의사항: 가이드 문서만 수정했고, 기존에 잘못 등록된 문제 데이터(choiceSetPolicy 변경 + 선택지 재생성)는 별도 작업 필요. 처리 여부는 원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 선택지 형태가 stem과 안 맞으면 등록 가이드·프롬프트의 정책 매핑부터 본다.
