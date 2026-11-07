---
type: issue
id: ISS-0478
created: 2026-11-07
topics: [practice, ai]
symptoms: ["웹 AI 새 보기 설정 무시", "웹 매번 같은 검증된 보기", "웹 설정 연습 실전 옛 이름", "웹 풀이 보기 방식 칩 없음", useQuestionChoices.ts, Settings.tsx]
root_cause: "웹 useQuestionChoices 가 회원 보기 방식과 관계없이 검증된 보기 세트를 먼저 썼다 (앱이 #863 에서 고친 것과 같은 종류)"
status: resolved
resolution: "[[ISS-0478-web-solving-ignores-fresh-choice-mode-report]]"
related: ["[[DEC-0275-choice-mode-chip-applies-before-submit]]", "[[ISS-0475-choice-mode-switch-current-question]]", "[[ISS-0461-plan-aligned-options-new-choices-mode]]", "[[DEC-0251-practice-reuse-random-validated-sets]]"]
source: "https://github.com/Twin-Fang/passQL/issues/913"
---

# ISS-0478: 웹 풀이가 AI 새 보기 설정을 무시함, 설정 이름 옛 표기, 보기 방식 칩 없음

GitHub #913 (https://github.com/Twin-Fang/passQL/issues/913). #907([[ISS-0475-choice-mode-switch-current-question]]) 작업 중 발견. 원본 사본: `_sources/issues/ISS-0478-web-solving-ignores-fresh-choice-mode.md`(로컬).

## 증상
- 웹 풀이 화면은 회원 보기 방식이 "AI 새 보기"여도 기존 검증된 보기 세트를 먼저 씀 (`client/src/hooks/useQuestionChoices.ts`).
- 웹 설정 화면은 옛 이름 "연습 / 실전" (`client/src/pages/Settings.tsx`). 앱과 [[DEC-0261-real-mode-renamed-new-choices]]는 "AI 새 보기 / 검증된 보기", "실전"은 모의고사 이름.
- 웹 풀이 화면에 보기 방식 칩이 없음.

## 재현 조건
프로 회원으로 웹 설정에서 "실전"(새 보기) 선택 > 검증된 보기 세트가 있는 문제 풀이 > 매번 같은 검증된 보기.

## 조사 기록
- 2026-11-07: 57f351a9, PR #916 머지.

## 근본 원인
웹 보기 조회가 모드 기준([[DEC-0251-practice-reuse-random-validated-sets]]: 새 보기 모드는 검증 세트가 있어도 생성)을 따르지 않고 검증 세트 우선이었다. 앱은 #863([[ISS-0461-plan-aligned-options-new-choices-mode]])에서 같은 버그를 고쳤지만 웹은 남아 있었다.
