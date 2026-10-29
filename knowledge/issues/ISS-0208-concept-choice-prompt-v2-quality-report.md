---
type: completion-report
id: ISS-0208
created: 2026-10-07
topics: [ai, question-bank]
status: resolved
resolves: "[[ISS-0208-concept-choice-prompt-v2-quality]]"
related: ["[[ISS-0203-odd-one-out-choice-gen-fails]]"]
source: "https://github.com/Twin-Fang/passQL/issues/363"
---

# ISS-0208 완료 리포트: 개념 선택지 프롬프트 v2 적용, v1 세트 61개 `DISABLED`

GitHub #363 「처리 결과」·「증적 보충」·「기존 v1 선택지 교체 완료」 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 마이그레이션 `V0_0_229` 적용: 운영 DB `generate_choice_set_concept` v2 활성, v1 비활성, 모델 gemini-3.5-flash-lite, 온도 0.5.
- v1 프롬프트(`b5b739d5…`)로 생성된 개념 문제 OK 세트 61개(문제 50개)를 `DISABLED`로 전환(행 삭제 없음, 되돌리기 가능). FAILED 이력과 겹치는 문제 0개라 GitHub #358 추천·데일리 필터에 영향 없음. 이후 해당 문제를 처음 푸는 순간 v2 프롬프트(`16b02339…`)로 새로 생성.

## 근본 원인 (확정)
v1 프롬프트 규칙 부족 (v1/v2 비교표).

## 재발 방지
실측: 데이터 모델링 토픽 1번(주식별자, "옳지 않은 것") 진입 → v2 세트 즉시 생성(v2 OK 세트 2 → 3), 정답 C, A·B·D는 사실인 설명. 남은 점: v2에서도 "항상" 같은 단서 표현이 한 건 나옴(조인 원리) — 지속 관찰.

## 교훈
(원본에 없음, 볼트 정리) 프롬프트를 바꿔도 이미 저장된 OK 세트는 그대로 재사용된다 — 새 프롬프트를 적용하려면 기존 세트를 비활성화해 재생성을 유도해야 한다.
