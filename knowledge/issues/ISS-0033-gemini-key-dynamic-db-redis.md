---
type: issue
id: ISS-0033
created: 2026-04-09
topics: [ai, security]
symptoms: ["Gemini API Key 고정", "키 변경 시 재시작", gemini_client.py, "API 키 로그 평문", ai.gemini_api_key]
root_cause: "Gemini API Key가 `application.yml` 환경변수에만 있고 AI 서버가 시작 시 고정 주입받아 런타임 교체가 불가했다"
status: resolved
resolution: null
related: ["[[DEC-0032-gemini-key-runtime-from-settings]]"]
source: "https://github.com/Twin-Fang/passQL/issues/47"
---

# ISS-0033: Gemini API Key를 DB·Redis에서 동적 관리

GitHub #47 (원본: 이슈 본문. 댓글 없음).

## 증상
- Gemini API Key가 환경변수(`application.yml`)에만 고정되어 키 변경 시 서버 재시작이 필요했다.
- AI 서버(`gemini_client.py`)가 시작 시점에 키를 고정 주입받아 런타임 교체가 불가능했다.
- 민감 정보(API Key)가 로그에 평문으로 노출될 위험이 있었다.

## 재현 조건
키를 바꾸려면 서버 재시작이 필요 (이슈 본문).

## 조사 기록
- 댓글 없음. 완료 내용은 원본에 없다.

## 근본 원인
키를 시작 시점 설정으로만 주입하는 구조 (이슈 본문).
