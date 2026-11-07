---
type: completion-report
id: ISS-0475
created: 2026-11-07
topics: [practice, ai]
status: resolved
resolves: "[[ISS-0475-choice-mode-switch-current-question]]"
related: ["[[DEC-0275-choice-mode-chip-applies-before-submit]]", "[[ISS-0478-web-solving-ignores-fresh-choice-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/907"
---

# ISS-0475 완료 리포트: 적용 판정 planChoiceModeSwitch(제출 전 즉시, 제출 뒤 다음 풀이), 생성 겹침 없음, 오답 노트 칩 숨김, 문제 탭 스위치 줄 제거

GitHub #907 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/907#issuecomment-6702224608). PR #912 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0475-choice-mode-switch-current-question-report.md`(로컬).

## 해결 방법
- `choice_mode_switch_plan.dart`: 판정 순서 제출 여부 > 이미 받은 세트 재사용 > 진행 중 생성 합류 > 새로 받기(SSE). 할 일 5가지(`keepUntilNextSolve`, `showReadyChoiceSet`, `showFreshChoiceSet`, `awaitInFlightGeneration`, `generateChoices`). 입력은 실효 모드(무료는 서버 `FeatureAccessPolicy`와 같은 규칙으로 검증된 보기).
- 제출 전: 바로 교체, 고르던 선택 비움. 제출 뒤: 채점한 보기 유지 + "제출한 문제라 다음 풀이부터 적용돼요".
- 칩 연타해도 같은 문제 생성 1회(진행 중 생성 합류, 받아 둔 세트 재사용).
- 오답 노트 진입 `?entry=wrong-note`에서 칩 숨김(회원 설정 방식 그대로). 문제 탭 "새 보기로 풀기" 스위치 줄 제거(`choice_mode_shortcut_row.dart` 삭제). 바꾸는 곳은 풀이 칩 + 설정.
- [[DEC-0275-choice-mode-chip-applies-before-submit]].

## 검증
- `flutter analyze` 0건, `flutter test` 128개(적용 판정 5개), 코드 점검 새 위반 0.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 생성 겹침 방지는 판정의 재사용, 합류 두 단계. 빼거나 순서를 바꾸면 연타마다 LLM 생성.
- 제출을 시작한 뒤에는 보기를 바꾸지 않는다(채점 세트와 화면 불일치 방지).
- 오답 노트에서 풀이로 가는 새 길은 `?entry=wrong-note`를 붙여야 칩이 숨는다.

## 남은 일
- 배포 뒤 실측은 후속 댓글. 웹은 #913에서 처리.

## 교훈
전역 설정을 화면 안에서 바꾸게 하면 "지금 화면에 언제 반영되는가"와 "이미 확정된 결과(제출)를 건드리는가"를 판정 하나로 명시해야 한다.
