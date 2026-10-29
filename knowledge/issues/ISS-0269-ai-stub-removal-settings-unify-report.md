---
type: completion-report
id: ISS-0269
created: 2026-10-15
topics: [ai]
status: resolved
resolves: "[[ISS-0269-ai-stub-removal-settings-unify]]"
related: ["[[DEC-0122-remove-python-ai-stubs]]", "[[DEC-0125-embedding-model-env-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/463"
---

# ISS-0269 완료 리포트: 스텁 3개 삭제, `ai_service.py` 3분할, 설정 Settings 통합

GitHub #463 구현 보고서(2026-10-15) 기준.

## 해결 방법
- 안전망 먼저: Spring이 부르는 엔드포인트 8개의 계약 스냅샷과 동작 고정 테스트.
- 삭제: `explain-error`, `diff-explain`, `similar` 스텁과 전용 요청·응답 모델.
- 분리: `ai_service.py`(436줄) → 문제 생성·벡터 색인·추천 서비스 3개, 외부 호출은 clients 계층.
- 설정: `QDRANT_API_KEY` 별도 파싱 제거 → Settings 필드, 버전은 importlib.metadata, 임베딩 모델은 `.env` 단일 원본.
- 규칙 테스트: apis가 clients를 직접 import 금지 등. `ai/CLAUDE.md` 갱신.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: pytest 21개, 운영 run `38697240810`, `GET /health` → `{"status":"ok"}`, `POST /api/ai/index-status` 정상(Qdrant 192건), `ENVIRONMENT=prod`에서 `QDRANT_API_KEY` 정상 로드.
- 주의(원본): 임베딩 모델을 바꾸려면 `.env.prod`를 고치고 전체 재색인. 운영 DB `app_setting`에 Gemini API 키가 평문 저장 — 암호화나 Secret 이동 검토 필요(이후 #458에서 #492로 분리).

## 교훈
(원본에 없음, 볼트 정리) 임베딩 모델 설정을 바꾸는 경로를 만들면 기존 색인 차원과 맞는지부터 확인한다.
