---
type: decision
id: DEC-0289
created: 2026-11-12
reviewed: null
topics: [billing, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0496-daily-set-free-trial-sql-ai]]", "[[DEC-0004-free-pro-feature-boundary]]"]
---

# DEC-0289: 무료 회원도 오늘의 세트 문제에서는 SQL 실행·AI 해설을 쓴다

## 결정
무료 회원은 오늘의 세트 문제(KST 오늘 배정분)에 한해 SQL 실행, 전체 해설, 실행 오류·오답 AI 해설을 쓸 수 있다. 랜덤 풀기·모의고사 등 그 밖은 PRO 경계 그대로([[DEC-0004-free-pro-feature-boundary]]의 예외). 판정은 서버 `QuestionFeatureAccessPolicy`.

## 배경
첫 화면이 내세우는 차별점이 무료 회원에게 첫 문제부터 잠겨 신뢰가 떨어졌다(#992).

## 대안
- 로그인·온보딩 문구에 PRO 표시 → 버림: 첫인상이 약해짐.
- 그대로 둠 → 버림: 약속과 실제 불일치.

## 결과
- 체험 뒤 랜덤 풀기에서 PRO로 이어지는 흐름. 판정 클래스가 FeatureAccessPolicy와 분리됨(300줄 초과로 별도 클래스).
- 실행 오류·오답 AI 해설 호출 상한 없음(세트 문제 범위).

## 영향 범위
QuestionFeatureAccessPolicy, ProResponseRedactor, QuestionController·AiController, 문제 상세 isDailySetFreeTrial, 앱 question_feature_lock_providers·daily_set_free_trial_note, 이용권 비교표.
