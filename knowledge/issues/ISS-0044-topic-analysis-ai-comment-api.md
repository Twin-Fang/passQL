---
type: issue
id: ISS-0044
created: 2026-04-10
topics: [progress-stats, ai]
symptoms: ["/api/progress", "토픽별 정답률 없음", "레이더 차트", "AI 영역 분석 코멘트", topic-analysis, ai-comment]
root_cause: "통계 화면용 토픽별 정답률·토픽별 문제 수·AI 코멘트를 주는 API가 없었다"
status: resolved
resolution: null
related: ["[[ISS-0047-topic-analysis-ai-comment-impl]]", "[[DEC-0042-ai-comment-cache-evict-on-submit]]", "[[DEC-0043-topic-correct-rate-last-7-days]]"]
source: "https://github.com/Twin-Fang/passQL/issues/71"
---

# ISS-0044: 통계 화면용 토픽별 분석·AI 코멘트 API 부재

GitHub #71 (원본: 이슈 본문만, 댓글 없음). `작업전` 라벨인 채로 2026-04-10에 닫혔고 완료 기록은 없다.

## 증상
`GET /api/progress`는 풀 문제 수, 정답률, 연속 학습일, 합격 준비도만 준다. "내 실력, 한눈에" 화면에 필요한 토픽별 정답률(레이더 차트), 토픽별 문제 수(가로 막대), AI 영역 분석 코멘트 API가 없다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-04-10: 이슈 본문 제안 — `GET /api/progress/topic-analysis`, `GET /api/progress/ai-comment`(LLM latency를 고려해 별도 API, 비동기 로딩). 정답률은 최근 7일·문제별 최근 시도 기준. AI 코멘트는 `GeminiClient`(gemini-2.5-flash-lite)로 생성하고 `lastSubmissionCount` 비교로 변화 기반 캐싱. `TopicAnalysisService`(PQL-Domain-Submission), `AiCommentService`(PQL-Domain-AI).
- (원본에 없음, 볼트 정리) 같은 기능의 구현 리포트가 GitHub #79 본문에 있다. 두 이슈는 서로를 언급하지 않는다.

## 근본 원인
기능 미구현.
