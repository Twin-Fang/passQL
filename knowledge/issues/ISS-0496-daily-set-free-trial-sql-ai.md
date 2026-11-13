---
type: issue
id: ISS-0496
created: 2026-11-12
topics: [billing, practice, ai]
symptoms: ["첫 문제부터 PRO 잠금", "약속과 실제가 다름", "isDailySetFreeTrial", "QuestionFeatureAccessPolicy", "SQL 실행 잠금"]
root_cause: "로그인·온보딩이 SQL 실행·AI 해설을 내세우지만 무료 회원은 첫 문제부터 이 기능이 PRO 잠금이었다"
status: resolved
resolution: "[[ISS-0496-daily-set-free-trial-sql-ai-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/992"
---

# ISS-0496: 무료 회원도 오늘의 세트에서 SQL 실행·AI 해설 체험

GitHub #992.

## 증상
로그인·온보딩이 'SQL 직접 실행, AI 해설'을 차별점으로 내세우는데 무료 회원은 온보딩 직후 첫 문제에서 PRO 흐림 화면을 만남.

## 근본 원인
기능 판정(FeatureAccessPolicy)이 등급만 보고 문제 맥락(오늘의 세트)을 보지 않았다.
