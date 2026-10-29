---
type: issue
id: ISS-0100
created: 2026-04-12
topics: [ai, practice]
symptoms: ["AI 피드백 반복", "ai-comment:{memberUuid}", "Redis 캐시 키", AiCommentService, "프롬프트 하드코딩", PracticeResult, "Step2 Step3 분리", border-l-4]
root_cause: "AI 코멘트 Redis 캐시 키가 멤버 단위로 고정되고 프롬프트에 이번 세션 결과가 들어가지 않았다"
status: resolved
resolution: "[[ISS-0100-ai-comment-session-feedback-step-merge-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/181"
---

# ISS-0100: 퀴즈 결과 AI 분석 — 세션 단위 피드백과 Step 통합

GitHub #181 (원본: 이슈 본문, 리포트·영상 댓글).

## 증상
- AI 피드백 문구가 항상 동일하게 반복된다 — Redis 캐시 키가 `ai-comment:{memberUuid}`로 고정.
- 이번 세션의 정오답이 피드백에 반영되지 않는다 — Gemini에 누적 통계만 전달.
- 프롬프트가 `AiCommentService` 소스에 하드코딩되어 배포 없이 수정 불가.
- 결과 화면 Step2(AI 분석)·Step3(문제별 결과)가 분리되어 UX 단절. AI 코멘트 카드의 `border-l-4`, 불필요한 greeting 문구("괜찮아요!" 등).

## 재현 조건
퀴즈 세션을 바꿔 여러 번 풀고 결과 화면 진입 → 같은 AI 텍스트.

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: 캐시 키 `ai-comment:{memberUuid}:{sessionUuid}` TTL 2시간, `findTopicResultsBySessionUuid`로 세션 결과를 `{sessionStats}`로 주입, 프롬프트를 Flyway `V0_0_100__add_ai_comment_prompt.sql`로 `prompt_template`에 이관, Step 통합.

## 근본 원인
캐시 키가 멤버 단위였고, 프롬프트 입력에 세션 결과가 없었다.
