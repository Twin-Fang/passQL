---
type: decision
id: DEC-0160
created: 2026-10-20
reviewed: null
topics: [ai, admin, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0344-admin-dashboard-stats-ai-cost]]", "[[ISS-0344-admin-dashboard-stats-ai-cost-report]]"]
---

# DEC-0160: AI 비용은 `ai_call_log`의 모델·토큰 × 앱 설정 단가표로 추정하고, 호출 기록은 요약 테이블 없이 400일 보관한다

## 문제 정의 (Context)
AI 호출 기록이 Python 경유 호출만 남고 모델명·토큰이 없어 사용량·비용을 알 수 없었다. Gemini는 API 키로 결제 잔액을 조회할 수 없다 (GitHub #557).

## 결정 (Decision)
- 모든 Gemini 직접 호출과 Python 경유 호출을 `ai_call_log`에 `call_source`, `model_name`, 입력·출력 토큰과 함께 남긴다.
- 비용 = `app_setting` 단가표(`ai.model_price_table`) × 토큰. 출력 단가는 thinking 토큰 포함. 월 예산 `ai.monthly_budget_usd`. 단가가 바뀌면 앱 설정에서 고친다(30초 안에 반영).
- 결제 상태는 잔액 조회 대신 무료 `models.get` 키 유효성 검사와 최근 24시간 실패 원인 분류(429 한도 초과, 403 결제·권한, 시간 초과·5xx, 기타)로 본다.
- 월별 12개월 그래프를 위해 요약 테이블 대신 `ai_call_log` 보관 기간을 30일에서 400일로 늘린다.

## 검토한 대안 (Alternatives)
- 요약 테이블: 리포트 근거 "하루 호출 수백 건 규모라 요약 테이블 대신 `ai_call_log` 보관 기간을 400일로 늘렸다."
- 결제 잔액 직접 조회: "Gemini는 API 키로 결제 잔액을 조회할 수 없다"(이슈 본문·리포트).
- 그 밖은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 결제가 끊기면 403 또는 429가 바로 늘어 대시보드에서 보인다(리포트 서술).

**부정**
- 토큰·비용은 배포 시점부터 집계된다. 이전 호출은 모델 "미기록", 비용 0.
- 대체 경로(Python 실패 > Gemini)는 두 건으로 기록된다.

## 영향 범위 (Scope)
`GeminiClient`, `AiGatewayClient`, `AiCallLog`, `AiCallLogService`, `AiCostCalculator`, `AiModelPrice`, `AiFailureCategory`, `GeminiApiKeyHealth`, `V1_26_0__admin_dashboard_statistics.sql`, 관리자 `statistics.html`·대시보드 AI 블록.

## 출처 (References)
- GitHub #557 리포트 댓글(2026-10-20), 운영 실측 댓글(2026-10-21)
- [[ISS-0344-admin-dashboard-stats-ai-cost]]
