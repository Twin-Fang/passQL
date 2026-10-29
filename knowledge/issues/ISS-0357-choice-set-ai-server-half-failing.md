---
type: issue
id: ISS-0357
created: 2026-10-22
topics: [ai, ops-infra]
symptoms: [AI_SERVER_UNAVAILABLE, "/api/ai/generate-choice-set", "선택지 생성 실패", "즉시 거절", ai_call_log, AiGatewayClient, exchangeWithPython, GeminiFallbackClient, "18건 중 9건 실패"]
root_cause: ""
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/575"
---

# ISS-0357: 선택지 생성 AI 서버 호출 절반 실패, 원인 조사

GitHub #575 (원본: 이슈 본문). 열린 이슈.

## 증상
- 운영 선택지 생성(`/api/ai/generate-choice-set`) Python AI 서버 호출이 2026-10-16 ~ 10-21 18건 중 9건 실패.
- 실패 9건 모두 `error_type = AI_SERVER_UNAVAILABLE`, 응답 10~444ms — 시간 초과가 아니라 즉시 거절. 성공 건은 1.5~3초.
- 같은 날 같은 AI 서버의 `/api/ai/recommend`, `/api/ai/index-question`은 실패 0건.
- `AiGatewayClient.exchangeWithPython`은 연결 실패, 4xx/5xx, 응답 JSON 파싱 실패를 전부 `AI_SERVER_UNAVAILABLE` 하나로 기록해 원인 구분이 안 된다.
- 실패 뒤 `GeminiFallbackClient` 대체 호출이 갔는지, 사용자가 선택지를 받았는지 확인되지 않는다(GitHub #557 배포 전에는 Gemini 직접 호출이 기록되지 않았다).

## 재현 조건
운영 DB `ai_call_log`에서 `endpoint_path = '/api/ai/generate-choice-set'`, `is_success = false` 9건(10-18 4건, 10-20 3건, 10-21 2건). 같은 시각 `recommend` 호출은 성공.

## 조사 기록
- 2026-10-22 운영 `ai_call_log` 조회: 실패 시각 10-18 06:02:44(252ms), 06:02:50(10ms), 11:42:02(444ms), 20:26:45(221ms), 10-20 22:19:30(174ms), 22:23:12(189ms), 22:45:02(184ms), 10-21 15:15:21(97ms), 15:15:26(11ms).
- 10-21 15:15 두 건은 AI 서버 Blue-Green 전환(GitHub #564) 시각과 겹친다(배포 중 전환 구간 가능성).
- `passql-back-blue`는 10-21 15:30에 시작돼 이전 실패 시점 백엔드 로그가 없다.
- 같은 기간 `question_choice_set` AI_RUNTIME: OK 25, FAILED 3, DISABLED 3.
- 조사할 것(이슈 본문): 실제 HTTP 상태 코드와 본문(422·401·5xx·연결 거부), 실패 요청의 문제 유형·요청 본문, 대체 Gemini 호출 성공 여부와 사용자 화면 결과, 실패 원인을 나눠 기록할지 여부.

## 근본 원인
원본에 적혀 있지 않다(조사 전).
