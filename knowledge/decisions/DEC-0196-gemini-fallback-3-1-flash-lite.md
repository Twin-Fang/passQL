---
type: decision
id: DEC-0196
created: 2026-10-27
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0418-gemini-fallback-model-3-1-flash-lite]]", "[[ISS-0418-gemini-fallback-model-3-1-flash-lite-report]]", "[[DEC-0188-ai-connections-priority-fallback]]"]
---

# DEC-0196: 2순위 Gemini 대체 모델은 `gemini-3.1-flash-lite` (1순위 `claude-haiku-5-5` 유지)

## 문제 정의 (Context)
2순위 Gemini 연결의 기본 모델 `gemini-2.5-flash-lite`는 선택지 생성 성공률이 78%였고, 상위 후보 `gemini-2.5-flash`는 이 키로 404였다 (GitHub #719).

## 결정 (Decision)
- 관리자 "AI 연결"의 `gemini-default` 기본 모델을 `gemini-3.1-flash-lite`로 바꾼다. 코드 변경 없음.
- 호출 순서는 그대로: 1순위 `claude-haiku-5-5`, 2순위 `gemini-3.1-flash-lite`.
- 선택 이유(이슈 본문): 비용 1.7배에 성공률 78% → 96%, 해설 정확도 83% → 97%.

## 검토한 대안 (Alternatives)
- `gemini-3.5-flash-lite`: 성공률은 같고 해설 정확도는 더 낮은데 비용 3.3배.
- `gemini-3.8-flash`: 100%지만 비용 9.2배, 2027년에는 약 18배로 오름. 2순위 대체 모델로는 과함.
- `gemini-2.5-flash`: 이 키로 호출 불가(404).
- `gemini-3-flash-preview`: 미리보기 모델이라 제외.
- `gemini-2.5-flash-lite` 유지: 성공률 78%.

## 결과 (Consequences)
**긍정**
- 대체 경로 성공률 96%, 해설 정확도 97%.

**부정**
- 1건 비용 $0.00072 → $0.00124. 2순위라 1,000건 모두 Gemini여도 $0.72 → $1.24 정도(이슈 본문).

## 영향 범위 (Scope)
운영 `ai_connection`의 `gemini-default` 행(관리자 AI 연결 화면). Spring·AI 서버 대체 호출 경로.

## 출처 (References)
- GitHub #719 이슈 본문 「선택 이유」, 리포트 댓글
- [[ISS-0418-gemini-fallback-model-3-1-flash-lite]]
