---
type: completion-report
id: ISS-0074
created: 2026-04-11
topics: [ai]
status: resolved
resolves: "[[ISS-0074-anti-equivalence-prompt-v4]]"
related: ["[[DEC-0055-multiple-correct-ai-fallback-save]]"]
source: "https://github.com/Twin-Fang/passQL/issues/126"
---

# ISS-0074 완료 리포트: 프롬프트 v4 동치 패턴 금지 + MULTIPLE_CORRECT fallback 저장

GitHub #126 리포트 댓글 기준 (2026-04-11).

## 해결 방법
- `V0_0_73__improve_choice_set_prompt_anti_equivalence.sql`: `generate_choice_set` v3 `is_active = FALSE`, v4 INSERT. system_prompt에 7가지 동치 패턴(키워드 변형, 조건 방향 전환, GROUP BY 컬럼 조합, 컬럼 별칭 변형, ORDER BY 기본값, 서브쿼리 ↔ JOIN 변환, 불필요한 DISTINCT)을 예시와 함께 금지.
- `ChoiceSetSaveService.saveWithAiCorrect()` 추가(`sandboxValidationPassed=false`, AI `isCorrect` 직접 사용). `ChoiceSetGenerationService.generate()` 최종 실패 분기: `MULTIPLE_CORRECT`이고 AI `isCorrect=true`가 1개 이상·전체 미만이면 fallback 저장 후 반환, 전부 정답이거나 0개면 기존대로 에러.

## 근본 원인 (확정)
v3의 추상 규칙만으로는 AI가 동치 변형을 오답으로 반복 생성했다.

## 재발 방지
리포트 주의사항: v4는 `WHERE NOT EXISTS` 가드로 재실행 시 중복 INSERT 없음. Sandbox 검증(`CHOICE_SET_VALIDATION_MULTIPLE_CORRECT`)은 유지되고 프롬프트는 빈도만 줄인다. 새 동치 패턴이 발견되면 v5 마이그레이션으로 추가. fallback 세트는 `sandbox_validation_passed=false`로 남아 품질 모니터링에 쓸 수 있다.

## 교훈
리포트 서술: 동치 패턴 목록은 실제 실패 사례 기반으로 만들었다.
