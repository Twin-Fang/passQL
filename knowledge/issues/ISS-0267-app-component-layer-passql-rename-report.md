---
type: completion-report
id: ISS-0267
created: 2026-10-15
topics: [design-system, dev-workflow]
status: resolved
resolves: "[[ISS-0267-app-component-layer-passql-rename]]"
related: ["[[DEC-0120-pq-prefix-to-passql]]"]
source: "https://github.com/Twin-Fang/passQL/issues/461"
---

# ISS-0267 완료 리포트: `Pq*` → `Passql*`, 공통 컴포넌트·`AppRoutes`, 규칙 테스트

GitHub #461 구현 보고서(2026-10-15) 기준.

## 해결 방법
- 이름: `Pq*` → `Passql*`, 파일명을 주된 타입명에 맞춤, `context.passqlColors`, boolean `is/has/should` 접두사.
- 계층: `SessionExpirySignal`로 core → presentation 역방향 의존 제거, 위젯·flow의 API 직접 호출을 provider·service로, 라우트 문자열을 `AppRoutes`로.
- 공통 컴포넌트: `showPassqlConfirmDialog`, `PassqlLoadingIndicator`, `PassqlStatusScaffold`, `QuestionSolvingBody`, `SafeCallSlot`, `PassqlIconSize`.
- 오류 매핑을 서버 ErrorCode(#460)에 맞춤, SSE는 `errorCode` 우선.
- 규칙 테스트(`test/architecture`): 화면 코드의 `Color(0x`, `Colors.white/black`, 직접 대화상자·시트 호출, 계층 역방향 import 금지(예외는 테스트 안 목록으로만).
- 삭제: macos·linux·windows, `app/docs/be-api-docs.json`. `Design.md`와 규칙 문서를 Passql 코드 기준으로 다시 씀.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본: 새 화면에서 색 값·대화상자를 직접 쓰면 규칙 테스트가 실패한다 — 토큰이나 공통 컴포넌트를 먼저 추가한다. 오류 코드 매핑은 서버 ErrorCode 이름에 묶여 있다.
- 검증: `flutter analyze lib test tool` 문제 없음, `flutter test` 235개 통과, TestFlight run `38697275880`, Play run `38697278483`(심사 제출 안 함).

## 교훈
원본 재발 방지 문장과 같음.
