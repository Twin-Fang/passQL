---
type: decision
id: DEC-0184
created: 2026-10-27
reviewed: null
topics: [auth-member, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0407-new-member-onboarding-screens]]", "[[ISS-0407-new-member-onboarding-screens-report]]"]
---

# DEC-0184: 앱 온보딩은 신규 가입자에게만 계정당 한 번, 4장 뒤 오늘의 세트 첫 문제로 이어지고 알림 권한은 묻지 않는다

## 문제 정의 (Context)
신규 가입자가 로그인 직후 안내 없이 홈으로 넘어가 첫 문제까지 시간이 걸렸다 (GitHub #683).

## 결정 (Decision)
이슈 본문:
- 목표는 신규 가입자가 **첫 문제를 푸는 것**.
- 대상은 **신규 가입자만**(로그인 응답 `isNewMember`), 계정당 한 번. 기존 회원에게는 보여 주지 않는다.
- 흐름: 로그인 → 온보딩 4장(INSERT > SELECT > EXPLAIN > COMMIT) → 오늘의 세트 첫 문제('첫 문제' 배지) → 축하 화면 → 남은 문제 이어서 풀기.
- 상단 바 가운데 페이지 인디케이터, 오른쪽 '건너뛰기', 로고 없음. 그림 자산 없이 디자인 토큰과 기존 컴포넌트로만, 라이트·다크 지원.
- 알림 권한은 온보딩에서 묻지 않고 결과 화면 뒤 기존 알림 안내를 쓴다.
- 서버 변경 없음.

## 검토한 대안 (Alternatives)
논의 기록 없음. (리포트: 온보딩을 탭 셸 밖 루트 경로로 둬 탭 셸이 맨 위일 때만 뜨는 `NotificationPermissionPrompter`가 끼어들지 않게 했고, 그래서 축하 화면에 알림 카드를 따로 두지 않았다.)

## 결과 (Consequences)
**긍정**
- 논의 기록 없음 (측정 결과 없음).

**부정**
- '첫 문제' 배지는 세트 첫 문제 기준이라 이어 풀기로 중간부터 들어오면 맞지 않을 수 있다(신규 회원은 해당 없음).
- 로그인 처리 순서에 의존(`markPending()`이 세션 반영보다 먼저).

## 영향 범위 (Scope)
`app/lib/presentation/providers/auth_provider.dart`, `onboarding_providers.dart`, `app/lib/main.dart`, `app/lib/router/app_router.dart`, `pages/onboarding/`, `widgets/onboarding/`, `pages/questions/chapter_page.dart`.

## 출처 (References)
- GitHub #683 이슈 본문 「해결 방안」, 리포트 댓글 「주요 구현 내용」
- [[ISS-0407-new-member-onboarding-screens]]
