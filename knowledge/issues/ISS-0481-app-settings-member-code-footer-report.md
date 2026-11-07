---
type: completion-report
id: ISS-0481
created: 2026-11-07
topics: [auth-member]
status: resolved
resolves: "[[ISS-0481-app-settings-member-code-footer]]"
related: ["[[ISS-0482-admin-search-member-code]]"]
source: "_sources/issues/ISS-0481-app-settings-member-code-footer.md"
---

# ISS-0481 완료 리포트: 앱 설정 하단에 웹과 같은 회원 번호 표시·복사

## 해결 방법
- `app/lib/presentation/widgets/settings/settings_footer.dart`: `memberCode` 를 받아 `회원 번호 PQL-XXXXXXXX` 로 표시, 누르면 복사하고 "회원 번호가 복사되었습니다." 안내. 회원 번호가 없는 옛 응답이면 `회원 ID <UUID>`.
- `settings_page.dart` 가 `/members/me` 의 `memberCode` 를 넘김.
- PR #928 머지, 시뮬레이터(운영 서버)에서 전후 캡처 확인. `flutter analyze` 0건, 테스트 141개.

## 근본 원인 (확정)
서버·모델은 #908 에서 회원 번호를 이미 내려 줬고, 앱 하단만 UUID 를 썼다.

## 재발 방지
- 회원 번호 표기 원본은 서버 한 곳(이후 `MemberCode`, [[ISS-0482-admin-search-member-code]]).
- 관리자 검색이 회원 번호를 받는지는 이 이슈 범위 밖이라 #929 로 분리.

## 교훈
같은 회원 식별값을 보여 주는 화면(웹·앱·관리자)이 서로 다른 값을 쓰는지 먼저 비교한다.
