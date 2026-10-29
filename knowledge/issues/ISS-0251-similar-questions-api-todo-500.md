---
type: issue
id: ISS-0251
created: 2026-10-08
topics: [ai, practice]
symptoms: [유사 문제 섹션 안 보임, "GET /api/ai/similar", UnsupportedOperationException, TODO, 500, AiService.getSimilar, 실패 시 섹션 숨김]
root_cause: "`AiService.getSimilar()`가 `throw new UnsupportedOperationException(\"TODO\")` 상태이고 전역 예외 처리기에 핸들러가 없어 매번 500, 화면은 실패 시 섹션을 숨겨 드러나지 않았다"
status: resolved
resolution: "[[ISS-0251-similar-questions-api-todo-500-report]]"
related: ["[[DEC-0113-similar-via-recommend-reuse]]"]
source: "https://github.com/Twin-Fang/passQL/issues/442"
---

# ISS-0251: 유사 문제 API가 미구현(TODO)이라 매번 500 — 결과 화면 유사 문제 섹션이 항상 숨겨짐

GitHub #442 (원본: 이슈 본문과 리포트 댓글).

## 증상
정답·오답 결과 화면의 "유사 문제" 섹션이 웹·앱 모두에서 한 번도 보인 적이 없다. 화면은 실패 시 섹션을 숨겨 겉으로는 문제가 없어 보이지만 서버는 호출마다 500.
- 웹: `client/src/pages/AnswerFeedback.tsx` → `useSimilarQuestions(questionUuid, 3)`
- 앱: `app/lib/presentation/widgets/result/similar_questions_section.dart` → `getSimilar(questionUuid, 3)`

## 재현 조건
결과 화면 진입 시 `GET /api/ai/similar/{questionUuid}` 호출 → 500.

## 조사 기록
- 2026-10-08: Python AI 서버 `similar`도 "아직 구현되지 않았습니다" 상태 확인.

## 근본 원인
frontmatter `root_cause`와 같음.
