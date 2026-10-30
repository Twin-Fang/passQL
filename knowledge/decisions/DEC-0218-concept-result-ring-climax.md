---
type: decision
id: DEC-0218
created: 2026-10-30
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0220-check-on-semantic-fill-uses-on-semantic]]"]
---

# DEC-0218: 개념 결과는 문제마다 한 칸씩 차오르는 이어진 고리 + 햅틱, 5/5만 원·체크·폭죽, 단원 숫자는 `+1` 뒤 굴러 바뀐다

## 문제 정의 (Context)
개념 확인 문제 결과 화면을 더 인터랙티브하게 만들자는 요청 (GitHub #764 시안 검토). 사용자는 "게이지 단계별로 올라갈 때 시간 두고 하나씩 가게 하고 갈 때마다 진동, 클라이맥스처럼"을 요청했다.

## 결정 (Decision)
- 고리는 칸으로 나누지 않은 이어진 고리. 맞힐 때마다 1/N씩 차고 색은 `accent`에서 `correct`로 보간된다.
- 문제 한 칸 간격 약 0.35초, 칸마다 햅틱(정답은 약한 진동에서 점점 세게, 오답은 선택 진동).
- 5/5면 안쪽을 고리 색으로 채운 원 + 선으로 그려지는 체크 + 폭죽 + 가장 센 진동. 폭죽은 만점일 때만.
- 단원 진행은 `n / 8 개념` 큰 숫자. 칩이 아닌 보라 글자 `+1`이 먼저 뜨고 숫자가 새 값으로 굴러간 뒤 버튼이 나타난다.
- 시간은 `PassqlMotion.conceptResult*` 토큰. 동작 줄이기면 끝 상태로 바로, 화면을 탭하면 건너뛴다.
- 새 패키지 없이 `CustomPainter`로 그린다.

## 검토한 대안 (Alternatives)
- 칸이 나뉜 고리: 사용자가 "원형은 이어져 있는 게 낫지 않냐"고 해 이어진 고리로.
- `+1` 칩: 사용자가 "헷갈리지 않나", "+1 칩으로 하지 말고"라며 듀오링고식 숫자 애니메이션(+1 후 숫자 변경, 그 뒤 버튼 생성)을 골랐다.
- 5/5에 `5/5` 글자: 사용자가 체크로 바꾸고, 안쪽을 고리와 같은 색으로 채운 뒤 체크가 그려지게 하자고 했다.

## 결과 (Consequences)
**긍정**
- 결과를 글 대신 고리·색·체크로 읽는다.

**부정**
- 연출 전체가 수 초 걸린다 (탭으로 건너뛰기 제공). 실제 기기 햅틱 강도는 확인하지 못했다.

## 영향 범위 (Scope)
`app/lib/presentation/widgets/concept/concept_result_view.dart`, `concept_result_ring.dart`, `concept_confetti.dart`, `design/tokens/passql_motion.dart`, `design/passql_haptics.dart`(`playLight`), `providers/concept_providers.dart`(`topicSolvedCountAtStart`).

## 출처 (References)
- GitHub #764 이슈 본문(결과 타임라인 표)과 리포트 댓글 6512843324
- [[ISS-0432-app-concept-tab-redesign]]
