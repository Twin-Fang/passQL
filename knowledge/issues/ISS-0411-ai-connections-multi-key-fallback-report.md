---
type: completion-report
id: ISS-0411
created: 2026-10-27
topics: [ai, admin]
status: resolved
resolves: "[[ISS-0411-ai-connections-multi-key-fallback]]"
related: ["[[DEC-0188-ai-connections-priority-fallback]]"]
source: "https://github.com/Twin-Fang/passQL/issues/695"
---

# ISS-0411 완료 리포트: 관리자 "AI 연결" 메뉴와 우선순위 대체 호출

GitHub #695 리포트 댓글 기준.

## 해결 방법
- 관리자 > AI > **AI 연결**: Gemini·Claude·OpenAI 키 여러 개 등록, 호출 순서, 사용 켜기·끄기, 키 확인. 기능별 모델은 프롬프트 관리의 모델 칸.
- 호출 규칙(Spring `AiChatClient`·AI 서버 `llm_client` 동일): 프롬프트 모델의 제공자 연결이 있으면 그 연결들을 프롬프트 모델로 먼저, 나머지는 각자의 기본 모델로. 없으면 모든 연결을 우선순위대로 기본 모델로.
- 다음 연결로: 응답 없음, 401, 402, 403, 404, 429, 5xx, 크레딧 부족·한도·무효 키 문구가 있는 400. 그 외 400은 즉시 실패.
- 모델 이름 규칙: `claude-*` Claude, `gemini-*` Gemini, `gpt-*`·`o1`·`o3`·`o4` OpenAI.
- 데이터: 새 테이블 `ai_connection`(키 암호문, AAD `ai_connection:{uuid}`), Redis `passql:ai:connections`에 암호문 그대로 공유, 기동 시 연결이 없으면 `ai.claude_api_key`·`ai.gemini_api_key`를 이관하고 행 삭제, `ai.model_override`·`ai.gemini_model`·`ai.default_model` 정리, `ai_call_log.connection_name` 추가.
- OpenAI 클라이언트(Spring·AI 서버, `json_object` 모드). 대시보드·모니터링 "Gemini 키" 표시를 "AI 연결 (1순위)"로(모델 조회 1회, 5분 캐시). 연결 변경은 감사 로그(키 마스킹).
- 운영 상태: 1순위 `claude-passql-pro`(`claude-haiku-5-5`), 2순위 `gemini-default`(`gemini-2.5-flash-lite`).

## 근본 원인 (확정)
연결 단위 관리·대체 순서 부재.

## 재발 방지
- 새 제공자를 추가할 때 그 제공자의 키 오류·한도 오류 응답 형식을 먼저 확인(Gemini `400 API_KEY_INVALID` 사례).
- 대체 규칙은 Spring(`AiFallbackPolicy`, `AiCallAttemptPlanner`)과 AI 서버(`llm_client.py`) 두 곳 — 같이 바꾸고 양쪽 테스트를 함께 고친다.
- 연결 목록은 Spring에서 30초 캐시.
- OpenAI는 키가 없어 실제 호출 미확인.
- 테스트: Spring 전체 통과(시도 순서·대체 판정·대체 호출·스키마 변환 8개 추가), AI 서버 45개 통과(`test_app_version_comes_from_package_metadata` 1건은 기존 환경 문제).

## 교훈
(원본에 없음, 볼트 정리) 대체(fallback) 판정은 HTTP 상태만으로 부족하다 — 제공자마다 키 무효를 400 본문 문구로 알리는 경우가 있다.
