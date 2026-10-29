---
type: issue
id: ISS-0047
created: 2026-04-10
topics: [progress-stats, ai]
symptoms: ["토픽별 정답률", "레이더 차트", "AI 영역 분석", topic-analysis, ai-comment, "Redis 캐시", GeminiClient]
root_cause: "기존 /api/progress가 토픽별 정답률·문제 수·AI 코멘트를 제공하지 않았다"
status: resolved
resolution: "[[ISS-0047-topic-analysis-ai-comment-impl-report]]"
related: ["[[DEC-0042-ai-comment-cache-evict-on-submit]]", "[[DEC-0043-topic-correct-rate-last-7-days]]", "[[ISS-0044-topic-analysis-ai-comment-api]]"]
source: "https://github.com/Twin-Fang/passQL/issues/79"
---

# ISS-0047: "내 실력, 한눈에" 통계 화면용 토픽별 분석·AI 코멘트 API 구현

GitHub #79 (원본: 이슈 본문(구현 리포트 형식)과 댓글).

## 증상
통계 화면의 토픽별 정답률(레이더 차트), 토픽별 문제 수(가로 막대), AI 영역 분석 코멘트를 줄 API가 없었다(본문 개요).

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-10: 이슈 본문 자체가 구현 내용(DTO·쿼리·서비스·캐싱)을 담은 리포트다.
- 2026-04-11: 스크린샷과 "정상 적용 확인 완료" 댓글.

## 근본 원인
기능 미구현.
