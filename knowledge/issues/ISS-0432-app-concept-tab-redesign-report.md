---
type: completion-report
id: ISS-0432
created: 2026-10-30
topics: [concept-learning, design-system]
status: resolved
resolves: "[[ISS-0432-app-concept-tab-redesign]]"
related: ["[[DEC-0217-concept-study-single-segment]]", "[[DEC-0218-concept-result-ring-climax]]", "[[DEC-0219-keep-one-line-headlines-visualize-instructions]]", "[[DEC-0220-check-on-semantic-fill-uses-on-semantic]]", "[[DEC-0168-text-only-color-tokens]]"]
source: "https://github.com/Twin-Fang/passQL/issues/764#issuecomment-6512843324"
---

# ISS-0432 완료 리포트: 개념 탭을 구간 + 회색 띠 구조, 세그먼트 3칸, 결과 고리 연출로 개편

GitHub #764 리포트 댓글 6512843324 기준 (2026-10-30). 커밋 0553fa56. 새 패키지 없이 Flutter 기본 위젯과 `CustomPainter`만 썼고 서버·API는 바꾸지 않았다.

## 해결 방법
- 탭 첫 화면(`concepts_home_page.dart`): "N개 중 끝낸 개념" 큰 숫자 + 진행 막대 + 이어서 학습 한 줄 띠, 단원 목록은 상태 타일(완료 체크·진행 번호·대기 번호)과 `c/t`. 잠긴 단원은 `ProLockedSection` 유지.
- 단원 상세(`concept_topic_page.dart`): "N단원 · 이름" 머리, "남은 개념 N개" 큰 제목, 긴 개념 이름은 두 줄(`PassqlListRow.titleMaxLines` 추가). 요약 부제 제거, 오른쪽은 `맞힌 수/문제 수`·`읽음`만.
- 개념 화면(`concept_page.dart`): 읽기/풀기와 핵심/자세히 두 줄을 세그먼트 한 줄 `핵심 | 자세히 | 문제`로 합침 → [[DEC-0217-concept-study-single-segment]]. 하단 버튼 순서(왼쪽 문제 풀기, 오른쪽 다음 개념)는 지금 앱 그대로.
- 읽기(`concept_read_view.dart`): 핵심은 "꼭 기억할 것 N가지", 자세히는 "문단 N개 · 약 M분"(분당 500자, 표 줄 제외) + 번호 붙은 문단.
- 풀기(`concept_solve_view.dart`): 점 진행 줄(현재 문제만 긴 알약, 맞음 초록·틀림 빨강, 숫자는 점 줄에만).
- 결과(`concept_result_view.dart`, `concept_result_ring.dart`, `concept_confetti.dart`): 문제마다 고리 한 칸 + 햅틱, 색은 보라 → 초록 보간, 5/5면 원 채움 + 그려지는 체크 + 폭죽, 단원 `n / 8 개념` 숫자가 `+1` 뒤 굴러 바뀌고 버튼 등장 → [[DEC-0218-concept-result-ring-climax]]. 한 줄 제목은 남기고 사용 안내 문장은 시각 요소로 → [[DEC-0219-keep-one-line-headlines-visualize-instructions]]. 체크 색은 `onSemantic` → [[DEC-0220-check-on-semantic-fill-uses-on-semantic]].
- 풀이 시트(`concept_answer_review_sheet.dart`): 칩을 누르면 문제·내 답·정답·풀이와 "이 부분 다시 읽기 · N. 문단 제목".
- 상태(`concept_providers.dart`): `topicSolvedCountAtStart`(한 번만 기록), `restartWrongOnly`(틀린 문제만 다시), `goToNextQuestion(questionUuids)`(채점한 문제 건너뜀).
- 토큰: `PassqlMotion.conceptResult*`·`confetti`, `PassqlHaptics.playLight`. 삭제: `passql_progress_ring.dart`, `PassqlSize.progressRing*`, `depthSwitchMaxWidth`.
- 스토어 캡처용 가짜 API(`tool/store_shots`)가 확인 문제를 다 푼 개념을 완료로 응답하도록 바꿔 `+1` 연출을 캡처.

검증: `flutter analyze` 이슈 없음, `flutter test` 92개 통과(디자인 규칙 테스트 포함). UI 변경이라 새 테스트는 없음. 시뮬레이터 라이트·다크 before/after 캡처와 영상.

## 근본 원인 (확정)
결함이 아니라 화면 구조 개편.

## 재발 방지
리포트의 주의사항:
- 결과 화면은 `ValueKey(study.resultByQuestion)`로 결과가 바뀔 때만 연출을 다시 돌린다. 키를 지우면 다시 그려질 때마다 연출이 처음부터 시작된다.
- 단원 `+1` 시작 값은 풀이 시작 때 기억한 `topicSolvedCountAtStart`라서 다시 풀어도 `+1`이 중복되지 않는다.
- `goToNextQuestion` 시그니처가 바뀌어 호출부(풀이 화면, 캡처 도구) 둘 다 반영했다.
- 다 틀렸을 때 제목 "다시 읽고 풀어 봐요"는 논의 없이 정한 문구.

화면으로 확인하지 못한 것: 표 제외 후 읽는 시간 값, 실제 기기 햅틱 강도. 테스트 빌드는 리포트 시점에 아직 돌리지 않았다.

## 교훈
(원본에 없음, 볼트 정리) 시뮬레이터 다크 캡처는 앱이 저장한 테마 설정(`flutter.theme_mode`)이 시스템 모드를 덮어 라이트로 찍힐 수 있다. 캡처 세트를 찍기 전에 첫 장 배경을 확인한다.
