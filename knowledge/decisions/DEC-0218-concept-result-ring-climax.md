---
type: decision
id: DEC-0218
created: 2026-10-30
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0220-check-on-semantic-fill-uses-on-semantic]]", "[[DEC-0222-concept-perfect-fullscreen-scoreboard]]"]
---

# DEC-0218: 개념 결과는 문제마다 한 칸씩 차오르는 고리 + 햅틱, 큰 연출은 다 맞힘 점수판 하나로

## 문제 정의 (Context)
개념 확인 문제 결과 화면을 더 인터랙티브하게 만들자는 요청 (GitHub #764 시안 검토). 사용자는 "게이지 단계별로 올라갈 때 시간 두고 하나씩 가게 하고 갈 때마다 진동, 클라이맥스처럼"을 요청했다. 개념이 63개라 매번 같은 폭죽은 질린다는 점도 논의됐다.

## 결정 (Decision)
- 틀린 문제가 있을 때 결과 화면 머리: 왼쪽 큰 제목 + 부제, 오른쪽 작은 이어진 고리. 맞힐 때마다 1/N씩 차고 색은 `accent`에서 `correct`로 보간. 문제 한 칸 약 0.35초, 칸마다 햅틱(정답은 약한 진동에서 점점 세게, 오답은 선택 진동).
- 스크롤하면 머리가 접혀 한 줄 제목 + 아주 작은 고리만 남는다.
- 단원 진행은 개념 수만큼 칸 막대. 이번에 끝냈으면 보라 `+1`(칩 아님)이 먼저 뜨고 숫자가 굴러 바뀌며 새 칸이 한 번 튄다. 이 뒤에 버튼이 올라온다.
- 다 맞히면 이 화면 대신 전체 화면 점수판 → [[DEC-0222-concept-perfect-fullscreen-scoreboard]].
- 단원을 다 끝내면 제목이 "N단원을 끝냈어요"로 바뀌고 가장 센 진동, 오른쪽 버튼이 "N+1단원 시작하기"가 된다.
- 시간은 `PassqlMotion.conceptResult*` 토큰. 동작 줄이기면 끝 상태로 바로, 화면을 탭하면 건너뛴다. 새 패키지 없이 `CustomPainter`.

## 검토한 대안 (Alternatives)
- 칸이 나뉜 고리: 사용자가 "원형은 이어져 있는 게 낫지 않냐"고 해 이어진 고리로.
- `+1` 칩: 사용자가 "헷갈리지 않나", "+1 칩으로 하지 말고"라며 듀오링고식 숫자 애니메이션(+1 후 숫자 변경, 그 뒤 버튼 생성)을 골랐다.
- 단원 끝에 별도 보라 전체 화면 한 장: 구현해 보였으나 사용자가 "너무 별로"라 해 결과 화면 안에서 제목이 바뀌는 방식으로 대체했다.
- 폭죽: 개념 63개마다 터지면 질리므로 단원 끝으로 한정했다가, 최종적으로 빛 번짐 하나만 남기고 모두 뺐다 → [[DEC-0222-concept-perfect-fullscreen-scoreboard]].

## 결과 (Consequences)
**긍정**
- 결과를 글 대신 고리·막대·목록으로 읽는다.

**부정**
- 연출 전체가 수 초 걸린다 (탭으로 건너뛰기 제공). 실제 기기 햅틱 강도는 확인하지 못했다.

## 영향 범위 (Scope)
`app/lib/presentation/widgets/concept/concept_result_view.dart`, `concept_result_ring.dart`, `design/tokens/passql_motion.dart`, `design/passql_haptics.dart`(`playLight`), `providers/concept_providers.dart`(`topicSolvedCountAtStart`).

## 출처 (References)
- GitHub #764 이슈 본문(결과 타임라인 표)과 리포트 댓글
- [[ISS-0432-app-concept-tab-redesign]]
