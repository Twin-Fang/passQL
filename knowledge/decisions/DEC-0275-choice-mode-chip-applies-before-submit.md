---
type: decision
id: DEC-0275
created: 2026-11-07
reviewed: null
topics: [practice, ai]
status: active
supersedes: DEC-0261
superseded_by: null
related: ["[[ISS-0475-choice-mode-switch-current-question]]", "[[ISS-0475-choice-mode-switch-current-question-report]]", "[[ISS-0478-web-solving-ignores-fresh-choice-mode]]", "[[ISS-0478-web-solving-ignores-fresh-choice-mode-report]]", "[[DEC-0261-real-mode-renamed-new-choices]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0275: 풀이 칩에서 보기 방식을 바꾸면 제출 전에는 지금 문제부터, 제출 뒤에는 다음 풀이부터 적용하고, 같은 화면의 생성은 겹치지 않으며, 바꾸는 곳은 풀이 칩과 설정 두 곳이다 (앱과 웹 같은 규칙)

## 문제 정의 (Context)
[[DEC-0261-real-mode-renamed-new-choices]]는 "새 보기로 풀기"(AI 새 보기 / 검증된 보기) 이름과 풀이 화면 칩을 정했다. 칩에서 바꾸면 다음 문제부터 적용돼 지금 문제에서 바로 새 보기를 볼 수 없었고, 보기 방식이 회원 설정 하나라 오답 노트에서 문제마다 칩이 보이는 것이 어색했다 (GitHub #907, [[ISS-0475-choice-mode-switch-current-question]]). 문제 탭의 "새 보기로 풀기" 스위치 줄은 화면으로 가는 다른 줄 사이에 섞여 있었다. 웹은 설정을 무시하고 검증된 보기를 먼저 썼고 칩도 없었다 (GitHub #913, [[ISS-0478-web-solving-ignores-fresh-choice-mode]]).

## 결정 (Decision)
- **적용 시점:** 칩에서 바꾸면 제출 전에는 지금 문제 보기를 바로 바꾼다(AI 새 보기는 그 자리에서 생성, 검증된 보기는 이 문제의 검증 세트로 즉시 교체, 고르던 선택은 비움). 제출을 시작한 뒤에는 채점한 보기를 유지하고 다음 풀이부터 적용하며 "제출한 문제라 다음 풀이부터 적용돼요"를 안내한다.
- **생성 겹침 없음:** 같은 화면에서는 받아 둔 세트를 재사용하고 진행 중 생성에 합류한다. 칩을 연타해도 같은 문제 생성은 1회.
- **판정 하나:** 제출 여부 > 이미 받은 세트 재사용 > 진행 중 생성 합류 > 새로 받기 순서의 `planChoiceModeSwitch`. 앱 `choice_mode_switch_plan.dart`와 웹 `choiceModeSwitchPlan.ts`가 같은 표를 쓴다. 입력은 실효 모드(무료는 서버와 같은 규칙으로 검증된 보기).
- **오답 노트:** 오답 노트 다시 풀기(`?entry=wrong-note`)에서는 칩을 숨기고 회원 설정 방식을 그대로 따른다.
- **바꾸는 곳 두 곳:** 풀이 화면 보기 위 칩 + 설정. 문제 탭 목록의 스위치 줄은 없앤다. 웹 설정의 "연습/실전"도 앱과 같은 "새 보기로 풀기" 스위치로.
- **웹도 모드를 지킨다:** 프로가 AI 새 보기면 검증 세트가 있어도 생성.
- **DEC-0261에서 그대로인 것:** 기능 이름 "새 보기로 풀기", 모드 이름 "AI 새 보기"(`REAL`), "검증된 보기"(`PRACTICE`). "실전"은 모의고사에만([[DEC-0264-mock-exam-fixed-rounds-server-judged]]). 새 보기 모드는 검증 세트가 있어도 매번 새로 생성([[DEC-0251-practice-reuse-random-validated-sets]]). 무료는 시트 안 잠금 미리보기, 등급 판정은 서버. 혜택 목록 이름 "새 보기, 토픽"([[DEC-0262-pro-benefits-seven-ad-removal]]).

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문이 "지금 문제에 바로 적용"과 "오답 노트에서 칩 숨김"을 처음부터 제시했고, 문제 탭 스위치 줄 제거는 범위 추가 댓글에서 정했다.)

## 결과 (Consequences)
**긍정**
- 바꾼 방식을 그 자리에서 확인하고, 연타해도 LLM 비용이 겹치지 않는다. 앱과 웹이 같은 방식으로 동작한다.

**부정 / 조건**
- 적용 판정이 앱과 웹 두 곳에 있어 함께 고쳐야 한다 (리포트 「주의할 점」).
- 새 보기 모드의 프로는 문제마다 생성 대기와 AI 비용이 생긴다(DEC-0261에서 이어짐). 웹이 설정을 지키게 되어 배포 뒤 웹 생성 호출이 늘어난다.

## 영향 범위 (Scope)
앱 `choice_mode_switch_plan.dart`, `question_providers.dart`, `question_interaction_state.dart`, `choice_mode_sheet.dart`, `choice_mode_indicator.dart`, `topic_list_page.dart`, `app_routes.dart`. 웹 `useQuestionChoices.ts`, `useEffectiveChoiceMode.ts`, `choiceModeSwitchPlan.ts`, `ChoiceModeChip.tsx`, `ChoiceModeSheet.tsx`, `Settings.tsx`, `FreshChoicesToggleRow.tsx`. 서버 모드 값과 판정은 그대로.

## 출처 (References)
- GitHub #907 이슈 본문, 범위 추가 댓글, 구현 확인 댓글, 리포트 댓글 (2026-11-07), PR #912
- GitHub #913 이슈 본문, 구현 확인 댓글, 리포트 댓글 (2026-11-07), PR #916
- 대체 대상: [[DEC-0261-real-mode-renamed-new-choices]] (#907 이슈 본문 「결정 기록: DEC-0261 일부 변경 > 새 결정 노트」)
- W4 충돌 검사: [[DEC-0251-practice-reuse-random-validated-sets]], [[DEC-0264-mock-exam-fixed-rounds-server-judged]]와 충돌 없음
