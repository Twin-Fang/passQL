---
type: completion-report
id: ISS-0300
created: 2026-10-16
topics: [design-system]
status: resolved
resolves: "[[ISS-0300-app-motion-system-reveal-badges]]"
related: ["[[DEC-0136-motion-via-tokens-only]]", "[[ISS-0302-app-server-web-performance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/495"
---

# ISS-0300 완료 리포트: `PassqlMotion` 토큰 확장, 공통 연출 컴포넌트, 탭 `StatefulShellRoute`, 규칙 테스트

GitHub #495 구현 보고서 댓글 기준 (main `d380b673`).

## 해결 방법
- `PassqlMotion`: 시간 5단계(120/250/300/450/700ms), 곡선 3종(기본, 웹 ease-smooth, 튀는 팝), 순차 간격 50ms(상한 8), 단어 등장 55ms·흐림 4px, 누름 축소 0.97, `isReduced`(동작 줄이기).
- 공통 컴포넌트: `PassqlReveal`·`passqlRevealInOrder`(페이드+위로 8px, 순번 지연), `PassqlFadeSwitcher`, `PassqlPopIn`(0.7→1.15→1배), `PassqlAiHeader`, `MarkdownLiteText(isAnimated)`(단어 순차 등장, 스크린리더는 줄 단위).
- `PassqlBadge`: `PassqlBadgeKind` 6종(주제·보조·완료·연속·중요·AI), 아이콘, 얇은 테두리. `PassqlPressable`, `PassqlButton` 누름 축소·상태 전환. `PassqlScoreHeader` 고리와 숫자 함께 증가.
- 통계: AI 코멘트를 `statsAiCommentProvider`로 분리, 위치를 요약 바로 아래로(웹과 같음). AI 해설 시트: 스켈레톤, AI 태그 팝, 단어 순차 등장, 높이 부드럽게, 오류 시 다시 시도.
- 탭: `StatefulShellRoute`로 탭마다 스크롤·데이터 유지, 전환은 페이드(`AppTabFadeStack`).
- 규칙 테스트: 화면 코드에서 `Curves.`, `duration: Duration(` 금지(스낵바 표시 시간 1곳만 예외).
- 검증: `flutter analyze` 0, `flutter test` 321개 통과. 시뮬레이터 촬영 중 찾은 문제 3건(불꽃 아이콘 중복, 대기 시트 전체 높이, 단어 등장 끝날 때 줄바꿈 튐) 수정.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본):
- 테스트에서 등장 연출을 기다릴 때 `pumpAndSettle`은 지연 타이머를 기다리지 않는다. `test/helpers/pump_app.dart`의 `pumpUntilMotionDone`을 쓴다.
- 애니메이션 모드 AI 글자는 단어마다 위젯이라 `find.textContaining`으로 문장 전체를 못 찾는다. `find.bySemanticsLabel`로 확인한다.
- 탭이 `StatefulShellRoute`라 탭 화면이 계속 살아 있다. 탭 진입마다 다시 받아야 하는 데이터는 provider 무효화로 처리한다.
- 남은 것: 스피너 → 스켈레톤, 챕터 다음 문제 미리 받기, 시작 속도, 웹 AI 해설 시트 진입 연출은 GitHub #497.

## 교훈
- (원본에 없음, 볼트 정리) 위젯 테스트가 연출 중인 화면에서 실패하면 `pumpUntilMotionDone`, `find.bySemanticsLabel`을 쓰는지 본다.
