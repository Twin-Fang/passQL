---
type: issue
id: ISS-0114
created: 2026-04-12
topics: [practice, design-system]
symptoms: ["이중 패딩", "좌우 여백 32px", StepNavigator, PracticeResult, PracticeFeedbackBar, btn-primary, "버튼 정렬선 불일치"]
root_cause: "PracticeResult 컨테이너와 StepNavigator step 패널에 px-4가 중복 적용되고 버튼 래퍼에 px-6이 더해졌다"
status: resolved
resolution: "[[ISS-0114-ai-report-padding-button-unify-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/205"
---

# ISS-0114: AI 리포트 화면 좌우 패딩 이상과 버튼 스타일 공통화

GitHub #205 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
- `PracticeResult` 컨테이너 패딩과 `StepNavigator` step 패널 패딩이 중복되어 좌우 여백이 의도의 2배.
- `StepNavigator` 하단 버튼 영역의 추가 가로 패딩으로 "다음" 버튼이 콘텐츠 정렬선보다 안쪽.
- `.btn-primary`가 있는데 `StepNavigator` "다음"과 `PracticeFeedbackBar` "계속하기/확인"이 각자 인라인 스타일이라 높이·radius 불일치.

## 재현 조건
퀴즈 완료 후 AI 리포트(`PracticeResult`) 화면, `PracticeSet` 피드백바.

## 조사 기록
- 2026-04-13: 리포트의 원인 분석 — 컨테이너 `px-4` + step 패널 `px-4` = 32px. `sm:px-0` 분기로 sm+에선 step 패널 패딩만 살아 있음. 버튼 래퍼 `px-6`(24px)까지 합쳐 버튼이 40px 안쪽. 버튼은 `h-12 rounded-xl`(48px / 12px) vs `.btn-primary`(44px / 8px).

## 근본 원인
패딩 책임이 두 레이어에 분산되고, 공통 버튼 클래스를 쓰지 않았다.
