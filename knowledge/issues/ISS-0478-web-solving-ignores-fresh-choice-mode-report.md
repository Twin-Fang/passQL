---
type: completion-report
id: ISS-0478
created: 2026-11-07
topics: [practice, ai]
status: resolved
resolves: "[[ISS-0478-web-solving-ignores-fresh-choice-mode]]"
related: ["[[DEC-0275-choice-mode-chip-applies-before-submit]]", "[[ISS-0475-choice-mode-switch-current-question-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/913"
---

# ISS-0478 완료 리포트: 웹도 회원 보기 방식을 지킴, 앱과 같은 칩과 적용 판정, 설정 이름 통일

GitHub #913 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/913#issuecomment-6702225119). PR #916 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0478-web-solving-ignores-fresh-choice-mode-report.md`(로컬).

## 해결 방법
- `useQuestionChoices.ts`: 프로가 AI 새 보기면 검증 세트가 있어도 SSE 생성, 검증된 보기면 고정 세트, 무료는 서버와 같은 규칙으로 검증된 보기. 생성 SSE는 `choiceGenerationStream.ts`, 실효 방식은 `useEffectiveChoiceMode.ts`.
- `choiceModeSwitchPlan.ts`: 앱 `choice_mode_switch_plan.dart`와 같은 판정 표(제출 전 즉시 교체와 선택 해제, 제출 뒤 유지와 안내, 생성 1회).
- `ChoiceModeChip.tsx`, `ChoiceModeSheet.tsx`: 풀이 화면 칩과 시트(무료 잠금 시트). 오답 노트 다시 풀기(`?entry=wrong-note`)에서는 숨김.
- `Settings.tsx`, `FreshChoicesToggleRow.tsx`: "연습/실전" 버튼을 앱과 같은 "새 보기로 풀기" 스위치로.
- [[DEC-0275-choice-mode-chip-applies-before-submit]].

## 검증
- `tsc` 통과, lint 0, vitest 37개(판정 6개), 코드 점검 새 위반 0.
- 가짜 API 실측(운영 API 차단 상태): 같은 문제 보기 교체, 되돌릴 때 생성 0회, 연타 생성 1회, 무료 저장 요청 0회, 오답 노트 칩 0개.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 적용 판정이 앱과 웹 두 곳에 같은 표로 있다. 한쪽을 바꾸면 다른 쪽과 두 판정 테스트를 같이 고친다.
- 웹 실효 방식 계산은 표시용, 등급 판정은 서버.

## 남은 일
- 운영 API로 실제 생성과 교체 확인은 배포 뒤 후속 댓글. 배포 뒤 웹 생성 호출이 늘어나는 것은 설정을 지키게 된 결과.

## 교훈
앱에서 고친 모드 버그는 웹에도 같은 분기가 있는지 함께 확인해야 한다. #863에서 앱만 고쳐 웹에 같은 버그가 남았다.
