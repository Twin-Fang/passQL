---
type: completion-report
id: ISS-0402
created: 2026-10-26
topics: [auth-member, design-system]
status: resolved
resolves: "[[ISS-0402-login-buttons-bottom-disabled-state]]"
related: ["[[DEC-0180-social-login-disabled-opacity-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/668"
---

# ISS-0402 완료 리포트: 소셜 버튼 하단 고정, 성공 후 잠금 유지, 나머지 버튼 흐림

GitHub #668 리포트 댓글 기준 (PR #669, `main` 머지, 앱 CI 통과).

## 해결 방법
- `login_page.dart`: Spacer(11:9)를 걷어내고 로고 위와 로고·버튼 사이에 같은 크기 Spacer. 버튼과 약관 사이는 `PassqlSpacing.md`(16). `_logoToButtonsGap` 상수 삭제.
- `login_page.dart`: 로그인 성공이면 `return`으로 빠져 잠금 유지, 취소·실패일 때만 `_signingInProvider`를 비움.
- `social_login_button.dart`: 비활성이면서 로딩 중이 아닌 버튼에 `Opacity` 0.4 (`_disabledOpacity`).
- `login_flow_test.dart`: 성공 직후 모든 버튼 `onPressed`가 `null`인지, 나머지가 흐려지는지 테스트(수정 전 실패 확인). `main_shots.dart`에 `/login-signing-in` 시나리오.

## 근본 원인 (확정)
`finally`에서 항상 잠금을 풀었다.

## 재발 방지
- 성공 후 잠금은 라우터가 홈으로 보낼 때 화면이 사라지는 것에 기댄다. 라우터 redirect 조건을 바꿀 때 버튼이 계속 잠기지 않는지 확인 필요.
- 앱 비활성 표시가 제각각(공용 버튼 회색, 로그인 버튼 투명도 0.4, 채점 후 선택지 카드 0.5)이고 디자인 시스템에 공통 값이 없다. 이번에 통일하지 않음.
- 확인하지 못함: 다크 모드, SE급 작은 화면, 실제 소셜 로그인 성공 순간.

## 교훈
(원본에 없음, 볼트 정리) 로딩 상태를 `finally`에서 일괄 해제하면 성공 후 화면 전환 구간에 재입력이 열린다.
