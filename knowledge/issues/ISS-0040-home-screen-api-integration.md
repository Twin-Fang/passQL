---
type: issue
id: ISS-0040
created: 2026-04-10
topics: [home, progress-stats]
symptoms: ["홈 화면 API 미연동", "/home/greeting", "/questions/today", "/exam-schedules/selected", "/questions/recommendations", "/progress/heatmap", readiness, useHome.ts]
root_cause: "백엔드 홈 API 6개는 구현돼 있었으나 프론트 홈 화면이 인사말·오늘의 문제·D-day·추천·히트맵·합격 준비도를 연동하지 않았다"
status: resolved
resolution: "[[ISS-0040-home-screen-api-integration-report]]"
related: ["[[DEC-0039-home-sections-independent-failure]]", "[[DEC-0034-greeting-nickname-template-message-type]]"]
source: "https://github.com/Twin-Fang/passQL/issues/67"
---

# ISS-0040: 홈 화면 미연동 API 6개 연동 명세

GitHub #67 (원본: 이슈 본문(FE 연동 가이드)과 댓글).

## 증상
홈(`/`)에서 사용자 이름, 스트릭, 푼 문제/정답률만 동작하고 동적 인사말(`GET /home/greeting`), 오늘의 문제(`GET /questions/today`), 시험 D-day(`GET /exam-schedules/selected`), 추천 문제(`GET /questions/recommendations`), 학습 히트맵(`GET /progress/heatmap`), 합격 준비도(`GET /progress`의 `readiness`)가 연동되지 않았다. 프론트 `GreetingResponse` 타입에는 `message`만 있었다.

## 재현 조건
해당 없음 (연동 작업 명세).

## 조사 기록
- 2026-04-10: 이슈 본문이 병렬 호출 흐름, 섹션별 독립 에러 처리, 훅 5개·`staleTime`, 히트맵 색상 5단계, readiness `toneKey × scoreBand` 24칸 카피 매트릭스(FE 관리)를 명세. "D-day 계산은 프론트에서 하지 않는다", "이모지 금지, lucide-react만".
- 2026-04-10: 백엔드 "홈화면 API 전부 구현 완료" 댓글, 프론트 작업 댓글.

## 근본 원인
프론트 연동 미완료.
