---
type: issue
id: ISS-0269
created: 2026-10-15
topics: [ai]
symptoms: [호출되지 않는 스텁, explain_error, diff_explain, similar, Ollama fallback 문서 불일치, Redis 모델 getter 미사용, 임베딩 차원 사본, "버전 0.0.1", "ai_service.py 436줄"]
root_cause: "AI 서버에 호출처 없는 스텁 3개, 436줄 단일 서비스, `.env`를 따로 파싱하는 설정 경로가 섞여 있었고 문서가 코드와 달랐다"
status: resolved
resolution: "[[ISS-0269-ai-stub-removal-settings-unify-report]]"
related: ["[[DEC-0122-remove-python-ai-stubs]]", "[[DEC-0125-embedding-model-env-only]]", "[[DEC-0118-single-source-commonization-rules]]"]
source: "https://github.com/Twin-Fang/passQL/issues/463"
---

# ISS-0269: AI 서버 미사용 스텁·설정 경로 혼재·문서 불일치

GitHub #463 (원본: 이슈 본문과 구현 보고서). 상위 GitHub #458.

## 증상
- `explain_error`·`diff_explain`·`similar`는 호출되지 않는 스텁(실제 기능은 Spring).
- 문서에 있는 Ollama fallback이 코드에 없다. Redis 모델 getter가 쓰이지 않는다.
- 컬렉션 이름과 임베딩 차원이 사본으로 있다. 버전이 0.0.1로 표시된다.

## 재현 조건
해당 없음 (구조 문제).

## 조사 기록
- 2026-10-15: 임베딩 모델을 관리자 설정(DB)에 연결했다가 되돌림 — 운영 DB `ai.ollama_embed_model`은 `bge-m3`인데 실제 컨테이너는 `.env.prod`의 `qwen3-embedding:4b`(2560차원)로 색인돼 있어 DB 값을 따르면 차원이 달라져 검색이 깨진다.

## 근본 원인
frontmatter `root_cause`와 같음.
