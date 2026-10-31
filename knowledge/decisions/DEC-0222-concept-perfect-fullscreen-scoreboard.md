---
type: decision
id: DEC-0222
created: 2026-10-30
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0218-concept-result-ring-climax]]", "[[DEC-0220-check-on-semantic-fill-uses-on-semantic]]"]
---

# DEC-0222: 다 맞히면 결과 화면 대신 듀오링고식 전체 화면 점수판을 보여 준다

## 문제 정의 (Context)
틀린 문제가 없으면 결과 화면에 머리와 단원 줄만 남아 반이 비었다 (GitHub #764). 사용자가 "문제 다 맞추면 전체화면으로 듀오링고처럼 스코어 보여주는 게 낫지 않냐"고 제안했다.

## 결정 (Decision)
- 5문제를 다 맞히면 상단 바 없이 화면 전체 점수판이 바로 뜬다(화면 전환 애니메이션 없음).
- 연출: 큰 고리가 맞힐 때마다 한 단계 커지며 숫자가 0→5로 오르고 진동 → 원이 튕기며 채워짐(탑승권 보라 그라데이션) → 체크가 선으로 그려짐 → 원 자리에서 보라 빛이 화면 끝까지 번지며 옅어지고 흰 빛줄기가 원을 한 번 스침 + 「완벽해요」 → 지표 카드 3장(정답 · N단원 · 전체)이 하나씩 톡 → 버튼.
- 폭죽은 단원을 끝낼 때(8번뿐)만: 아래 양쪽 구석 대포가 1시·11시로 쏴 엇갈리는 웹 canvas-confetti 물리, 중간부터 투명해지고 바닥 아래로 떨어지면 사라짐.
- 위계: 맨 위 단원 · 개념 이름 > 가운데 원·제목·부제 > 지표 카드 > 「다음 개념」 버튼과 글자 버튼 「다시 풀기」. 카드와 버튼 사이는 넓게 띄운다.
- 색은 앱 디자인 토큰만: 원은 파랑 계열 `accent`, 카드는 `accentTint` 바탕에 강조색 이름과 큰 본문색 숫자. 닫기 X는 없다.
- 단원까지 끝냈으면 같은 판에서 제목 「N단원을 끝냈어요」, 단원 카드 8/8, 버튼 「N+1단원 시작하기」. 지표는 지금 받는 값(정답 수, 단원 진행, 단원 목록 합)만 써서 서버 변경이 없다.
- 점수판 뒤에는 결과 화면(5/5)이 조용히 끝 상태로 남아, 뒤로 가면 그 화면이 보인다.

## 검토한 대안 (Alternatives)
- 결과 화면 아래를 지표 타일 + 다음 카드로 채우기: 사용자가 전체 화면 쪽을 골랐다.
- 위 보라 · 아래 흰 판(안 B): 다크에서 위아래 대비가 과해 흰 바탕 점수판(안 A)을 골랐다.
- 카드를 초록·파랑·주황으로 구분: 사용자가 색이 별로라 해 앱 공통 강조색 하나로 바꿨다. 색 머리띠 위 검정 글자도 안 읽힌다고 해 뺐다.
- 단원 끝만 별도 보라 한 장: "너무 별로"라 해 점수판 안에서 처리했다.
- 다 맞힐 때마다 폭죽: 위에서 쏟아지는 방식은 어색하다고 해 양쪽 대포로 바꿨고, 이후 매번 보기엔 시끄러워 단원 끝으로 옮겼다.
- 원에서 퍼지는 얇은 동심원 파동: 사용자가 "너무 별로"라 해 뺐다. 빛살+점 터짐·맞힌 개수 별·반짝이 별 시안도 함께 비교했고 사용자가 후광+빛줄기를 "화면 끝까지 퍼지게" 골랐다.

## 결과 (Consequences)
**긍정**
- 다 맞힌 순간이 한 화면에서 끝나고, 틀린 문제 화면과 겹치지 않는다.

**부정**
- 다 맞힘일 때 결과 화면이 두 번 보이는 구조(점수판 뒤에 5/5 결과 화면)라 뒤로 가기 동작을 같이 봐야 한다.

## 영향 범위 (Scope)
`app/lib/presentation/widgets/concept/concept_perfect_page.dart`(신규), `concept_glow.dart`(신규, 화면 끝까지 번지는 빛), `concept_confetti.dart`(양쪽 대포), `concept_result_view.dart`(점수판 호출), `concept_result_ring.dart`(`isAccentOnly`, `checkColor`, `diskGradientEnd`, `shineProgress`).

## 출처 (References)
- GitHub #764 시안 검토와 리포트 댓글
- [[ISS-0432-app-concept-tab-redesign]]
