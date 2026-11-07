---
type: completion-report
id: ISS-0470
created: 2026-11-07
topics: [auth-member, billing, ads]
status: resolved
resolves: "[[ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss]]"
related: ["[[ISS-0469-billing-switch-unverified-screens-races]]"]
source: "https://github.com/Twin-Fang/passQL/issues/880"
---

# ISS-0470 완료 리포트: UIScene 전환과 네이버 장면 이벤트 복귀, 등급 유지 새로고침, 확인 Future 전달, AppLogger 전환

GitHub #880 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/880#issuecomment-6702223792). PR #897 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss-report.md`(로컬).

## 해결 방법
- iOS UIScene: `Info.plist`에 `FlutterSceneDelegate`, 플러그인 등록과 네이티브 광고 팩토리 2개를 `didInitializeImplicitFlutterEngine`으로 이동. 네이버 복귀 URL은 장면 이벤트 처리기 `NaverLoginUrlSceneHandler`(실행 중 복귀, URL로 새로 실행 모두, 연결은 가로채지 않음). SKAdNetwork Google 권장 50개.
- 등급: 새로고침은 마지막 값을 유지한 채 다시 받기. `MemberResponseGuard`(요청 세대 <-> 응답 세대)로 회원 전환 전 출발한 응답 버림(등급, 안 읽은 알림, 알림 설정). 알림 설정 연속 변경 경합 수정.
- 확인 중 시트 닫힘: 시트가 확인 Future를 호출부에 먼저 넘기고, 닫혀도 호출부가 끝까지 기다려 토스트, 탑승권 연출, 호출부 재시도 (`pro_offer_sheet.dart`, `rewarded_ad_bonus_button.dart`). 닫히는 중 pop이 아래 화면을 닫던 문제 수정.
- 로그: `debugPrint` 52건 > `AppLogger`, 동결 규칙 `app-no-debug-print`.
- `token_store.dart`: 복호화 키 소실만 저장분 삭제, 일시 오류는 보존 후 다음 읽기에서 재시도. iOS 쓰기는 첫 잠금 해제 이후 읽기 등급.

## 검증
- `flutter analyze` 0건, `flutter test` 117개, 동결 규칙 새 위반 0.
- PR 빌드, iPhone 16 Pro 시뮬레이터(iOS 18.3)에서 소셜 로그인 4종(카카오, 네이버, Google, Apple) 로그아웃 > 로그인 > 홈 진입 통과. 카카오톡과 네이버 앱 연동(앱 사이 전환)은 미확인.

## 근본 원인 (확정)
이슈 노트 「근본 원인」과 같음. UIScene에서는 앱 대리자 `open url`이 불리지 않아 장면 이벤트로 받아야 했다.

## 재발 방지
- 새 네이티브 플러그인, URL 처리는 `didInitializeImplicitFlutterEngine`과 장면 이벤트 쪽에 둔다. 네이버 장면 처리기의 `false` 반환을 `true`로 바꾸면 카카오, Google 복귀 URL이 전달되지 않는다.
- 회원별 상태를 새로 만들면 `MemberResponseGuard`를 붙인다.
- 확인 시트 결과는 반환값이 아니라 먼저 넘긴 확인 Future로 받는다.

## 남은 일
- 앱 배포 뒤 실기기 소셜 로그인과 운영 실측은 후속 댓글.

## 교훈
시트나 대화상자 안에서 시작한 비동기 확인은 화면 수명과 분리해야 한다. 결과를 닫힘 반환값에만 실으면 사용자가 닫는 순간 서버 반영과 화면 안내가 갈라진다.
