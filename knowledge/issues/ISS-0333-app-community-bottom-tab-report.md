---
type: completion-report
id: ISS-0333
created: 2026-10-26
topics: [community]
status: resolved
resolves: "[[ISS-0333-app-community-bottom-tab]]"
related: ["[[DEC-0157-community-bottom-tab]]"]
source: "https://github.com/Twin-Fang/passQL/issues/543"
---

# ISS-0333 완료 리포트: 앱 하단 탭에 토론 탭 추가, 설정의 "내 의견" 제거

GitHub #543 리포트 댓글 기준 (2026-10-26).

## 해결 방법
- `app_shell.dart` 탭 목록에 토론 탭, `app_router.dart`·`app_routes.dart`에 토론 탭 브랜치 라우트, 커뮤니티 피드를 탭 루트로 이동(`community_feed_page.dart` 뒤로 가기 없이), `settings_page.dart`에서 "내 의견" 제거.
- `app_shell_test.dart` 탭 개수·순서 검증 갱신.
- v1.25.0 첫 반영. 리포트 시점 main(v1.51.1) 하단 탭은 `홈 · 문제 · 토론 · 내 프로필` 4개 — 통계와 설정은 GitHub #602에서 "내 프로필"로 합쳐졌다.

## 근본 원인 (확정)
이슈 노트 참조.

## 재발 방지
- 탭 순서와 개수는 `app_shell_test.dart`가 고정한다. 탭을 바꾸면 테스트도 고친다.
- iPhone SE에서 탭 라벨 잘림은 실기기로 확인하지 않았다(여러 기기 검수는 GitHub #535로 적었으나 #535는 취소됨).

## 교훈
(원본에 없음, 볼트 정리) 웹과 앱의 내비게이션 진입점이 다르면 기능 접근성 차이가 생긴다 — 탭 구성은 두 플랫폼을 함께 본다.
