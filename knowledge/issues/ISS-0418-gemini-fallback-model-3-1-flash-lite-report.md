---
type: completion-report
id: ISS-0418
created: 2026-10-27
topics: [ai]
status: resolved
resolves: "[[ISS-0418-gemini-fallback-model-3-1-flash-lite]]"
related: ["[[DEC-0196-gemini-fallback-3-1-flash-lite]]"]
source: "https://github.com/Twin-Fang/passQL/issues/719"
---

# ISS-0418 완료 리포트: `gemini-default` 기본 모델을 `gemini-3.1-flash-lite`로 (설정만 변경)

GitHub #719 리포트 댓글 기준.

## 해결 방법
- 코드와 마이그레이션은 바꾸지 않고 관리자 "AI 연결"에서 `gemini-default`의 기본 모델을 `gemini-2.5-flash-lite` > `gemini-3.1-flash-lite`로 변경(2026-10-27 22:11).
- 호출 순서 그대로: 1순위 `claude-haiku-5-5`, 2순위 `gemini-3.1-flash-lite`.
- 비교(3회 안 성공 / 첫 시도 / 해설 정확도 / 1건 비용): `gemini-2.5-flash-lite` 78% / 61% / 83% / $0.00072, `gemini-3.1-flash-lite` 96% / 86% / 97% / $0.00124(1.7배), `gemini-3.5-flash-lite` 96% / 78% / 89% / $0.00234(3.3배), `gemini-3.8-flash` 100% / 100% / 100% / $0.00662(9.2배).
- 검증: 운영 DB `ai_connection` 값 확인, 연결 확인 `isValid: true`, 1025ms.

## 근본 원인 (확정)
대체 모델 성능 부족.

## 재발 방지
- `gemini-2.5-flash`는 모델 목록에 보여도 이 키로 호출하면 404. 목록에 보여도 실제 호출되는지 먼저 확인.
- 연결 확인은 모델 조회만 해 비용이 없지만 생성 품질은 확인하지 못한다. 모델을 바꿀 때는 운영 문제로 비교.
- 3.x 모델은 thinking 토큰도 출력 단가로 과금 — 가격표 배수만으로 실제 비용을 알 수 없다.

## 교훈
(원본에 없음, 볼트 정리) 모델 교체는 가격표가 아니라 운영 문제 기준 성공률과 실제 토큰 비용으로 비교한다.
