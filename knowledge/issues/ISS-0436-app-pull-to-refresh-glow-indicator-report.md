---
type: completion-report
id: ISS-0436
created: 2026-11-01
topics: [design-system]
status: resolved
resolves: "[[ISS-0436-app-pull-to-refresh-glow-indicator]]"
related: ["[[DEC-0229-refresh-wave-dots-fullscreen-glow-component]]", "[[DEC-0230-refresh-dots-above-large-title-fixed]]", "[[DEC-0231-refresh-glow-on-release-wave-while-holding]]", "[[DEC-0222-concept-perfect-fullscreen-scoreboard]]"]
source: "https://github.com/Twin-Fang/passQL/issues/772#issuecomment-6545221166"
---

# ISS-0436 완료 리포트: 당겨서 새로고침을 웨이브 점 + 화면 전체 빛 공통 컴포넌트로 교체

GitHub #772 리포트 댓글 6545221166 기준 (2026-11-01). PR #773 (main 대상).

> 머지 상태 (2026-11-01 00:13 기준): PR #773을 막 열었고 아직 머지되지 않았다. 코드 커밋은 `167efea3`(빛 공통화), `367cef3c`(새로고침 표시), `c11744e4`(빛이 화면 끝까지)이다. 머지되기 전에는 이 리포트를 "main에 들어갔다"는 근거로 쓰지 않는다.

## 해결 방법
- **`PassqlRefreshControl`(신규):**
  - 당긴 만큼 점 5개가 켜진다.
  - 끝까지 당기면 진동이 오고, 손을 뗄 때까지 물결이 돈다. 요청이 먼저 끝나도 물결은 계속된다.
  - 손을 떼는 순간 점 자리에서 보라 빛이 화면 끝까지 번진다.
  - 적용한 5곳: 홈 틀, 큰 제목 틀, 공지 목록, 토론 질문, 알림함.
- **`PassqlGlow`:** 개념 점수판 빛(`ConceptGlow`)을 디자인 시스템으로 옮겼다.
  - 가장 밝은 테두리가 화면에서 가장 먼 귀퉁이에 닿도록 끝 반지름을 0.88(밝은 테두리 위치)로 나눠 키웠다.
  - 옅어지는 곡선을 세제곱으로 늦췄다.
  - 점수판에도 같이 적용된다.
- **손 뗌:** 전역 포인터 경로로 받는다. refresh 상태에 들어오는 것도 손을 뗀 것으로 본다.
- **빛의 수명:** 빛 한 번을 오버레이 층에 스스로 끝나는 위젯으로 띄우고, 다시 불러오는 동안은 주기마다 새로 띄운다.
- **점의 위치:** 띠 위쪽부터 새로고침 띠 높이만큼 칸(`OverflowBox`)을 잡아 그 아래쪽에 고정한다. 큰 제목 화면은 새로고침 sliver를 큰 제목 바 앞에 두고 `indicatorOffset`만큼 내린다.
- **시간 토큰:** `PassqlMotion.refreshGlowLoop`(700·800·900ms 비교 뒤 800), `refreshWaveLoop`
- **디자인 규칙 테스트:** 화면에서 `CupertinoSliverRefreshControl(`을 직접 쓰는 것을 금지했다. `Design.md`와 `app/CLAUDE.md`도 갱신했다.
- **검증:** `flutter analyze` 문제 없음, `flutter test` 92개 통과, 시뮬레이터 라이트·다크(개념 탭·홈).
- **확인하지 못한 것:** 개념 점수판 빛의 새 모양과 동작 줄이기 상태는 시뮬레이터로 직접 보지 않았다.

## 근본 원인 (확정)
iOS 기본 스피너를 그대로 쓰고 있어서 앱 브랜드 연출과 결이 달랐다. 직접 만든 표시는 Cupertino 새로고침의 상태 전이 시점에 맞지 않았다. armed에서 요청이 시작되고, 손을 떼도 띠가 줄어든 뒤에야 refresh가 되고, 빠르면 armed에서 바로 done으로 가고, 띠 높이가 0이면 위젯이 사라진다. 이 시점에 빛을 묶어 두면 늦게 시작하거나 중간에 끊겼다.

## 재발 방지
- 새로고침 표시는 `PassqlRefreshControl` 하나로만 쓴다. 디자인 규칙 테스트가 막는다.
- 빛은 표시 위젯의 수명에 묶지 않는다. 빛 한 번은 스스로 끝나는 층으로 띄운다.
- 화면 녹화용 가짜 API는 즉시 응답하므로, 새로고침 중 모습은 `onRefresh`에 임시 지연을 넣은 빌드로 확인한다.

## 교훈
- 당겨서 새로고침에 연출을 붙일 때는 Cupertino 상태(armed·refresh·done)가 언제 바뀌는지부터 확인한다. 손 뗌은 상태로 알 수 없다.
- "빛이 끊긴다"거나 "끝까지 안 간다"는 증상이 보이면, 빛을 그리는 위젯이 먼저 사라지는지와 가장 밝은 테두리의 위치(그라데이션 비율)를 먼저 본다.
