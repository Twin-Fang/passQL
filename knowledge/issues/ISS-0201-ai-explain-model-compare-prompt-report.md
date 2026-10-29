---
type: completion-report
id: ISS-0201
created: 2026-10-08
topics: [ai]
status: resolved
resolves: "[[ISS-0201-ai-explain-model-compare-prompt]]"
related: ["[[DEC-0099-explain-model-gemini-3-5-flash-lite]]", "[[DEC-0100-explain-prompt-context-in-server]]"]
source: "https://github.com/Twin-Fang/passQL/issues/356"
---

# ISS-0201 완료 리포트: 해설 프롬프트 v2 + `gemini-3.5-flash-lite` 운영 적용

GitHub #356 이슈 본문 「결정」과 검증 댓글(2026-10-08, 운영 v0.5.1) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
- `AiExplainService`에 규칙·샘플 데이터·전체 선택지를 넣는다.
- Flyway `V0_0_228`로 프롬프트 v2(temperature 0.3, max 1024)를 넣고 v1 비활성.
- 운영 관리자 > 프롬프트 관리에서 확인: `diff_explain` v2(v1 비활성) `gemini-3.5-flash-lite`, `explain_error` v2(v1 비활성) `gemini-3.5-flash-lite`.

## 근본 원인 (확정)
v1 프롬프트 맥락 부족이 품질을 가장 크게 떨어뜨렸다 (2차 실험에서 프롬프트 보완이 품질을 가장 크게 올림).

## 재발 방지
서버 `AiExplainServiceTest` 4건(캐시 재사용, 마지막 제출 선택지 세트 비교, AI 실패 시 `AI_UNAVAILABLE`, 오류 해설 입력 전달) 통과. 관리자 화면에서 모델을 바로 바꿀 수 있다.

## 교훈
(원본에 없음, 볼트 정리) 해설 품질이 나쁘면 모델을 바꾸기 전에 프롬프트에 샘플 데이터·전체 선택지·문제 유형 규칙이 들어가는지부터 본다 — 이 실험에서는 프롬프트 보완 효과가 모델 차이보다 컸다.
