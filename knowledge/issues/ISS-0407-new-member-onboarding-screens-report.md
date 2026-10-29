---
type: completion-report
id: ISS-0407
created: 2026-10-27
topics: [auth-member, practice]
status: resolved
resolves: "[[ISS-0407-new-member-onboarding-screens]]"
related: ["[[DEC-0184-new-member-onboarding-to-first-question]]"]
source: "https://github.com/Twin-Fang/passQL/issues/683"
---

# ISS-0407 완료 리포트: 신규 가입자 온보딩 4장 → 오늘의 세트 첫 문제 → 축하 화면

GitHub #683 리포트 댓글 기준.

## 해결 방법
- 상태·라우팅: `storage_keys.dart`·`device_preferences.dart`에 `onboarding_pending` 키와 `remove()`, `onboarding_providers.dart`(신규, `markPending`·`clear`), `auth_provider.dart`가 신규 가입이면 세션 반영 전에 대기 표시, `main.dart`가 시작 시 플래그 읽기·로그아웃 시 삭제, `app_router.dart`에 `/onboarding`, `/onboarding/celebration`, 오늘의 세트 `?onboarding=true`.
- 화면: `onboarding_page.dart`(가운데 페이지 점, 오른쪽 '건너뛰기', 뒤로 가기 막음), `widgets/onboarding/` 4장, `onboarding_celebration_page.dart`(UPDATE 1행 수정됨 카드).
- 첫 문제: `question_flow.dart`·`daily_set_flow.dart`의 `isOnboarding`, `chapter_page.dart`의 '첫 문제' 배지·축하 화면·목록 로드 성공 시 플래그 해제.
- 디자인 시스템: `passql_nav_bar.dart` `middle`, `passql_page_dots.dart`(신규, 홈 출제 경향 캐러셀도 교체), `passql_bottom_action_bar.dart` `hasTopHairline`, `widgets/home/exam_dday.dart`(신규, 홈과 공유), `app/.claude/rules/Design.md` 갱신.

## 근본 원인 (확정)
기능 부재.

## 재발 방지
- `isNewMember`는 계정을 만드는 요청에만 `true`라 다시 받을 수 없어 받는 즉시 기기에 저장한다.
- 로그인 처리 순서를 바꾸지 않는다: `markPending()`이 `state = AsyncData(session)`보다 늦으면 라우터가 홈을 먼저 그린다. `main.dart` 인증 리스너도 `authProvider.future`를 기다린 뒤 등록해야 첫 실행에 플래그가 지워지지 않는다.
- 해제 시점은 문제 목록이 실제로 불러와졌을 때(로드 실패 시 플래그 유지).
- 플래그는 일반 설정 저장소에 두고 로그아웃 때 반드시 지운다.
- 기능 테스트는 GitHub #680 정책에 따라 새로 쓰지 않음. `flutter analyze` 무이슈, 규칙·계약 테스트 통과. 실계정 확인은 남음.

## 교훈
(원본에 없음, 볼트 정리) 한 번만 오는 서버 신호는 상태 반영 전에 저장해야 라우터 경쟁에서 지지 않는다.
