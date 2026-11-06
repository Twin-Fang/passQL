---
type: completion-report
id: ISS-0466
created: 2026-11-07
topics: [ai, security]
status: resolved
resolves: "[[ISS-0466-llm-duplicate-billing-retry-fallback]]"
related: ["[[DEC-0267-ai-retry-fallback-by-error-kind]]"]
source: "_sources/issues/ISS-0466-llm-duplicate-billing-retry-fallback-report.md"
---

# ISS-0466 완료 리포트: 재시도·대체 호출을 실패 종류(`error_kind`)로 나누고 AI 서버 보호 강화

GitHub #877 리포트 기준 (2026-11-07). 운영 배포 릴리스 #886.

## 해결 방법
- 재시도·대체 호출 정책 — [[DEC-0267-ai-retry-fallback-by-error-kind]]:
  - AI 서버: 연결 실패와 429 만 재시도, 요청 전체 120초 상한(서버 운영 대기 300초보다 짧게), 실패 응답에 `error_kind`.
  - 서버: 입력 오류는 새 에러 코드 `AI_SERVER_REQUEST_REJECTED`, 입력 오류·LLM 모두 실패는 대체 호출 없음·서킷 실패 아님, AI 서버 내부 오류·본문 없음만 직접 LLM 대체 호출. 선택지 재시도도 실패 종류로 나눔.
- AI 서버 보호: 운영 docs 끄기, `max_tokens` 16384 상한, temperature 범위 제한, 정리 요청 삭제 비율 50% 상한, UUID 422 검증.
- 정리: 벡터 일괄 조회, 템플릿 한 번 치환, 클라이언트 보관 상한, Redis 첫 연결 잠금, 로그 영어.
- 의존성 `uv.lock` 고정, Dockerfile 해시 검증 설치. 양쪽 계약 스냅샷 테스트 + CI 추가.

## 검증
- AI 서버 pytest 62개, 서버 테스트 89개, PR CI 전부 통과.

## 근본 원인 (확정)
실패 종류를 구분하지 않은 재시도·대체 호출, 두 서버의 재시도 정책 불일치.

## 재발 방지
- AI 서버 실패 응답은 `error_kind` 를 담고, 서버는 그 값으로만 대체 호출·서킷 실패·재시도를 정한다.
- AI 서버 요청 상한 시간은 서버 대기 시간보다 짧게 둔다.

## 알고 남긴 것 (사람이 해야 할 일)
- AI 서버 키 교체: 지금 키는 짧고 Ollama 키와 같음 > 서로 다른 강한 값으로 서버·AI 서버 설정을 함께 갱신.
- 앞단 프록시에 서버 IP 만 허용하는 목록.
- 관리자가 문제의 절반 넘게를 한꺼번에 비활성하면 정리 요청이 거부됨 > 컬렉션 재생성·재색인.

## 교훈
과금되는 외부 호출의 재시도는 "요청이 상대에게 도달했는가"로 나눈다. 시간 초과는 이미 과금됐을 수 있으므로 재시도하지 않는다. 여러 계층이 각자 재시도하면 곱으로 늘어난다.
