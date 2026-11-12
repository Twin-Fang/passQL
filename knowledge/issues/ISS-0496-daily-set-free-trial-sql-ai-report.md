---
type: completion-report
id: ISS-0496
created: 2026-11-12
topics: [billing, practice, ai]
status: resolved
resolves: "[[ISS-0496-daily-set-free-trial-sql-ai]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/992"
---

# ISS-0496 완료 리포트: 무료 회원도 오늘의 세트에서 SQL 실행·AI 해설 체험

## 해결 방법 (PR #997)
- 서버 `QuestionFeatureAccessPolicy`: 등급 허용 아니면 체험 기능(SQL 실행, 전체 해설, 실행 오류·오답 AI 해설) + 오늘의 세트 문제(KST, DailyQuestionCounter)일 때 허용.
- execute·explain-error·diff-explain 문제 기준 직접 검사, submit·choice-explanation 체험 문제면 응답 그대로. 문제 상세 `isDailySetFreeTrial`.
- 앱: 실행 잠금은 서버 표시 기준, 체험 안내 한 줄(기존 실행 안내 대신). 비교표 FREE 칸에 세트 체험 반영(#995).
- 결정: [[DEC-0289-daily-set-free-trial-sql-ai]].

## 재발 방지
- 무료/PRO 경계를 바꿀 때 첫 화면 문구(로그인·온보딩)와 실제 잠금이 맞는지 같이 본다.

## 교훈
- 실행 오류·오답 AI 해설은 호출 횟수 제한이 없음(세트 5문제 범위로 한정). 비용이 늘면 상한 검토.
