---
type: issue
id: ISS-0475
created: 2026-11-07
topics: [practice, ai]
symptoms: ["보기 방식 바꾸면 다음 문제부터 적용", "AI 새 보기 칩 지금 문제", "오답 노트 보기 방식 칩", "오답 노트에서 바꾸면 모든 문제 바뀜", "문제 탭 새 보기로 풀기 스위치", "칩 연타 생성 중복", choice_mode_sheet.dart, choice_mode_shortcut_row.dart, question_providers.dart]
root_cause: "보기 방식이 회원 설정 하나(전역)이고 칩 변경을 다음 문제 로드 때만 반영했으며, 오답 노트 진입을 구분하는 표시가 없었다"
status: resolved
resolution: "[[ISS-0475-choice-mode-switch-current-question-report]]"
related: ["[[DEC-0275-choice-mode-chip-applies-before-submit]]", "[[DEC-0261-real-mode-renamed-new-choices]]", "[[ISS-0461-plan-aligned-options-new-choices-mode]]", "[[ISS-0478-web-solving-ignores-fresh-choice-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/907"
---

# ISS-0475: 보기 방식 바꾸면 지금 문제부터 바로 적용, 오답 노트에서는 칩 숨김

GitHub #907 (https://github.com/Twin-Fang/passQL/issues/907). 칩은 #863([[ISS-0461-plan-aligned-options-new-choices-mode]], [[DEC-0261-real-mode-renamed-new-choices]])에서 생김. 웹은 [[ISS-0478-web-solving-ignores-fresh-choice-mode]](#913). 원본 사본: `_sources/issues/ISS-0475-choice-mode-switch-current-question.md`(로컬).

## 증상
- 풀이 화면 보기 위 "AI 새 보기 / 검증된 보기" 칩에서 바꾸면 다음 문제부터 적용. 지금 문제에서 바로 새 보기를 볼 수 없음.
- 보기 방식은 회원 설정 하나라, 오답 노트에서 문제마다 같은 칩이 보이고 거기서 바꾸면 다른 오답 문제도 모두 바뀜.
- (범위 추가 댓글) 문제 탭 목록의 "새 보기로 풀기"만 설정 스위치라, 화면으로 가는 다른 줄(SQLD 모의고사, 오답 노트) 사이에 섞여 어색함.

## 재현 조건
프로 회원, 검증된 보기로 풀이 중 칩에서 "AI 새 보기"로 바꿈 > 지금 문제 보기 그대로. 오답 노트 다시 풀기 화면에 칩 표시.

## 조사 기록
- 2026-11-07: 앱 890ef0d1, PR #912 머지. 작업 중 웹이 설정을 무시하는 문제 발견 > #913.

## 근본 원인
칩 변경이 회원 설정 저장만 하고 현재 문제의 보기는 다시 받지 않았다. 오답 노트 진입 경로를 구분하는 표시가 없어 칩을 숨길 수 없었다.
