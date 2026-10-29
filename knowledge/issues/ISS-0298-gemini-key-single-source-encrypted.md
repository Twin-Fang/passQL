---
type: issue
id: ISS-0298
created: 2026-10-16
topics: [ai, security]
symptoms: [Gemini API 키 원본 두 곳, GeminiClient yml 키, Redis passql:settings:ai.gemini_api_key, "관리자 키 변경 후 Java 서버 옛 키", 평문 저장, AppInitializer]
root_cause: "Java 서버는 yml 키를 기동 때 한 번 읽고 AI 서버는 Redis 키를 읽어 원본이 둘이었고, 기동 시 yml 키가 DB·Redis에 평문으로 복사됐다"
status: resolved
resolution: "[[ISS-0298-gemini-key-single-source-encrypted-report]]"
related: ["[[DEC-0133-encrypted-gemini-key-single-source]]"]
source: "https://github.com/Twin-Fang/passQL/issues/492"
---

# ISS-0298: Gemini API 키 원본이 두 곳이고 DB·Redis에 평문 저장

GitHub #492 (원본: 이슈 본문, 설계안 댓글, 구현 보고서 댓글). GitHub #458 리팩터링의 남은 일.

## 증상
- Java 서버 `GeminiClient`는 yml `gemini.api-key`를 기동 때 한 번만 읽고, AI 서버는 Redis `passql:settings:ai.gemini_api_key`를 먼저 읽고 없으면 env `GEMINI_API_KEY`.
- 관리자 화면에서 키를 바꾸면 AI 서버만 새 키를 쓰고, Java 서버(AI 서버 장애 시 fallback)는 옛 키를 계속 쓴다.
- 기동 시 `AppInitializer`가 yml 키를 DB `app_setting`과 Redis에 복사해 평문 저장. 관리자 화면은 마스킹만.
- 위치: `server/PQL-Domain-AI/.../GeminiClient.java`, `server/PQL-Web/.../AppInitializer.java`, `server/PQL-Domain-Meta/.../AppSettingService.java`, `ai/src/clients/redis_app_setting_client.py`.

## 재현 조건
관리자 화면에서 Gemini 키 변경 후 AI 서버 장애로 Java fallback 경로가 호출될 때(옛 키 사용).

## 조사 기록
- 2026-10-16 설계안 댓글: 결정 사항 표(키 원본, 저장 방식, 암호화 형식, 마스터 키, 기존 평문 처리)와 배포 순서. 이 시점 실제 서버에서 관리자 화면 키 변경 확인은 아직 하지 않음.
- 2026-10-16 구현 보고서: 다른 세션이 구현한 브랜치를 이어받아 통합·배포.

## 근본 원인
frontmatter `root_cause`와 같음.
