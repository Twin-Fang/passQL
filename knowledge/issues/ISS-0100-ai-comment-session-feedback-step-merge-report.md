---
type: completion-report
id: ISS-0100
created: 2026-04-12
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0100-ai-comment-session-feedback-step-merge]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/181"
---

# ISS-0100 완료 리포트: AI 코멘트 세션 단위 캐시·세션 결과 주입·프롬프트 DB 이관·결과 Step 통합

GitHub #181 `## 개요` 리포트 댓글 기준 (2026-04-12). 백엔드는 커밋 `f58173c`, 프론트 3개 파일은 리포트 시점 미커밋.

## 해결 방법
- `SubmissionRepository.findTopicResultsBySessionUuid(String sessionUuid)` Native Query(submission → question → topic JOIN).
- `AiCommentService.getAiComment(UUID memberUuid, UUID sessionUuid)`: sessionUuid optional. null이면 `ai-comment:{memberUuid}`, 있으면 `ai-comment:{memberUuid}:{sessionUuid}`, TTL 2h. `buildSessionStats()`가 "토픽명: 정답/오답" 텍스트를 `{sessionStats}`로 주입. 프롬프트는 `promptService.getActivePrompt("ai_comment")`로 DB 조회(코드 프리즈 후 가변 설정은 DB 경유라는 기존 결정 DEC-0011과 같은 방향).
- `SubmissionService`의 `redisTemplate.delete("ai-comment:" + memberUuid)` 제거.
- `ProgressController`: `sessionUuid` `required = false`, ApiLog #176.
- `V0_0_100__add_ai_comment_prompt.sql`: `ai_comment` 시드(`gemini-2.5-flash-lite`, temperature 0.7, max_tokens 400), `WHERE NOT EXISTS` 멱등.
- 프론트: `fetchAiComment(sessionUuid?: string)`, `PracticeResult.tsx` Steps 3개 → 2개, `useAiText`, `calcAiAnimDuration(text)` = `200 + (단어수-1) × 55 + 300 + 300` ms 후 문제 카드 순차 등장, `border-l-4`·greeting 제거, `queryKey: ["aiComment", sessionId]` `staleTime: 2h`. `Stats.tsx`는 인수 없이 호출(멤버 단위 캐시).

## 근본 원인 (확정)
멤버 단위 캐시 키와 세션 결과 미포함 프롬프트.

## 재발 방지
리포트 주의사항: 통계 화면 호출은 `sessionStats`에 "세션 데이터 없음" 고정값이 들어가 누적 통계만 반영. `buildSessionStats`의 `(Boolean) row[1]` 캐스팅은 DB 변경 시 `ClassCastException` 가능성 있어 방어 처리 고려.

## 교훈
(원본에 없음, 볼트 정리) AI 생성 문구가 매번 같으면 캐시 키의 범위(멤버/세션)부터 확인한다.
