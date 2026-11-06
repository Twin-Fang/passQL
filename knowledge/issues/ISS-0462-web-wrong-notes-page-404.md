---
type: issue
id: ISS-0462
created: 2026-11-07
topics: [practice, billing]
symptoms: ["오답 전체보기 404", /mypage/wrong-questions, "웹 오답 노트 화면 없음", "오답 다시 풀기 버튼 숨김", "제출 실패 오답 기록", "프로 잠금 403 무반응", MyPage.tsx]
root_cause: "웹 라우터에 오답 노트 화면이 없는데 마이페이지 전체보기가 그 주소로 이동했다"
status: resolved
resolution: "[[ISS-0462-web-wrong-notes-page-404-report]]"
related: ["[[ISS-0459-structured-ai-stats-analysis]]", "[[ISS-0460-ai-analysis-forecast-concept-links]]"]
source: "_sources/issues/ISS-0462-web-wrong-notes-page-404.md"
---

# ISS-0462: 웹 마이페이지 오답 전체보기 404, 웹 오답 노트 화면 없음

GitHub #865 (https://github.com/Twin-Fang/passQL/issues/865).

## 증상
- 웹 마이페이지 최근 오답 목록 "전체보기"가 라우터에 없는 주소(`/mypage/wrong-questions`)로 이동해 404 (`client/src/pages/MyPage.tsx:173`).
- 웹에 오답 노트 화면이 없어 통계 AI 분석의 "오답 다시 풀기" 버튼을 웹에서만 숨기고 있었음 (#861).

## 재현 조건
웹 로그인 > 마이페이지 > 최근 오답 "전체보기" 클릭 > 404. 서버 API `GET /api/progress/wrong-questions`(프로 전용)는 이미 있음.

## 조사 기록
- 2026-11-07: 작업 중 웹 버그 두 개 추가 발견 — 연습 문제 제출 실패가 오답으로 기록됨, 프로 잠금 403 을 받아도 반응 없음.

## 근본 원인
화면 없이 링크만 먼저 있었다 (웹 오답 노트 화면 미구현).
