---
type: decision
id: DEC-0136
created: 2026-10-16
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0300-app-motion-system-reveal-badges]]"]
---

# DEC-0136: 앱 모션은 `PassqlMotion` 토큰과 공통 연출 컴포넌트로만 쓰고, 외부 애니메이션 패키지는 넣지 않는다

## 문제 정의 (Context)
앱이 딱딱하고 모션 토큰이 시간 1개·곡선 1개뿐이었다. 웹에는 다듬어진 연출이 있었다 (GitHub #495).

## 결정 (Decision)
- 모션 시간·곡선·순차 간격은 `PassqlMotion` 한 곳에 둔다. 화면 코드에서 `Curves.`, `duration: Duration(` 직접 사용은 규칙 테스트로 막는다(스낵바 표시 시간 1곳만 이유를 적어 예외).
- 등장·교체·팝은 공통 컴포넌트(`PassqlReveal`, `PassqlFadeSwitcher`, `PassqlPopIn`, `PassqlAiHeader`, `MarkdownLiteText(isAnimated)`)로 감싸기만 한다.
- 수치는 웹 원본(이 이슈 첫 댓글 표)을 그대로 옮긴다.
- 접근성 동작 줄이기(`MediaQuery.disableAnimations`)를 켜면 연출을 생략한다. 순차 지연에는 상한(8)을 둔다.
- 외부 애니메이션 패키지(Lottie, Rive)는 넣지 않는다. Flutter 기본 위젯과 이미 쓰는 `animations` 패키지만 쓴다.

## 검토한 대안 (Alternatives)
- Lottie, Rive: 이슈 본문 "추가 요청 사항"에서 넣지 않는다고 정함. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 화면별 연출이 한 토큰 세트로 일관되고 웹과 수치가 같다.

**부정**
- 테스트에서 `pumpAndSettle`이 지연 타이머를 기다리지 않아 `pumpUntilMotionDone`이 필요하다.
- 애니메이션 모드 AI 글자는 단어 단위 위젯이라 텍스트 검색 대신 스크린리더 라벨로 확인해야 한다.

## 영향 범위 (Scope)
`app/lib/presentation/design/tokens/passql_motion.dart`, `design/components/*`(Badge, Pressable, Button, ScoreHeader 등), 홈·문제·통계·설정·AI 해설 시트, 앱 규칙 테스트.

## 출처 (References)
- GitHub #495 이슈 본문 "기대 결과", "추가 요청 사항", 구현 보고서 댓글(2026-10-16)
- [[ISS-0300-app-motion-system-reveal-badges]]
