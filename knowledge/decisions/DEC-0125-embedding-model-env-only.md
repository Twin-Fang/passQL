---
type: decision
id: DEC-0125
created: 2026-10-15
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0269-ai-stub-removal-settings-unify]]", "[[ISS-0269-ai-stub-removal-settings-unify-report]]"]
---

# DEC-0125: 임베딩 모델은 관리자 설정(DB)이 아니라 `.env` 단일 원본으로 둔다

## 문제 정의 (Context)
AI 서버 설정 단일화(GitHub #463) 중 임베딩 모델을 관리자 설정에 연결하려 했다. 운영 DB `ai.ollama_embed_model`은 `bge-m3`, 실제 색인은 `.env.prod`의 `qwen3-embedding:4b`(2560차원)였다.

## 결정 (Decision)
임베딩 모델은 관리자 설정을 읽지 않고 `.env` 단일 원본으로 둔다. 관리자 설정 연결은 되돌렸다. 모델을 바꾸려면 `.env.prod`를 고치고 전체 재색인한다.

## 검토한 대안 (Alternatives)
- 관리자 설정(DB `ai.ollama_embed_model`)을 따르기: DB 값을 따르면 차원이 달라져 검색이 깨지므로 되돌림(원본).

## 결과 (Consequences)
**긍정**
- 색인과 질의 임베딩 차원이 어긋나지 않는다.

**부정**
- 운영 DB의 `ai.ollama_embed_model` 값(`bge-m3`)은 실제 동작과 다르게 남는다(원본에 정리 계획은 적혀 있지 않다).

## 영향 범위 (Scope)
`ai/` Settings, `.env.prod`, Qdrant 색인, `app_setting`의 `ai.ollama_embed_model`.

## 출처 (References)
- GitHub #463 구현 보고서 주의사항 (2026-10-15)
