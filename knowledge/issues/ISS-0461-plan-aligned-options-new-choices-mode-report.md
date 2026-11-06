---
type: completion-report
id: ISS-0461
created: 2026-11-07
topics: [billing, practice, auth-member]
status: resolved
resolves: "[[ISS-0461-plan-aligned-options-new-choices-mode]]"
related: ["[[DEC-0261-real-mode-renamed-new-choices]]", "[[DEC-0262-pro-benefits-seven-ad-removal]]", "[[DEC-0263-pass-rows-on-account-screen-only]]"]
source: "_sources/issues/ISS-0461-plan-aligned-options-new-choices-mode-report.md"
---

# ISS-0461 완료 리포트: 실전 모드 > 새 보기로 풀기, 혜택에 광고 제거, 이용권 행 한 곳, 중복 진입점 정리

GitHub #863 리포트 기준 (2026-11-07). 운영 배포 릴리스 #888 (앱 스토어 심사 제출).

## 해결 방법
- "실전 모드" > "새 보기로 풀기", 모드 이름 "AI 새 보기"·"검증된 보기", 풀이 화면 보기 위 모드 칩 > 시트에서 변경, 무료는 시트 안 잠금 미리보기 — [[DEC-0261-real-mode-renamed-new-choices]].
- 버그 수정: 새 보기 모드면 검증 세트가 있어도 매번 새로 생성 ([[DEC-0251-practice-reuse-random-validated-sets]] 기준에 맞춤).
- 프로 혜택 목록에 광고 제거 추가 (결제한 프로는 실제로 광고 꺼짐) — [[DEC-0262-pro-benefits-seven-ad-removal]].
- 이용권 행(구매 복원·프로모션 코드·구매 내역)은 계정·이용권 화면 한 곳, 프로필은 "이용권 관리" 한 줄 — [[DEC-0263-pass-rows-on-account-screen-only]].
- 알림함 설정 행 제거, 홈 종 아이콘 하나 (규칙 테스트 예외 목록 비움).
- 토론 탭 제목 줄 더보기(…) > 차단한 사용자 관리. 닉네임 줄 연필 아이콘, 계정 화면 닉네임 행.
- 파일 위치 정리(동작 변경 없음): `pages/profile/profile_page.dart`, 오답 노트는 questions 쪽으로 이동.
- 같이 고친 것: 동작 줄이기 상태에서 사용량 게이지 디버그 오류 (애니메이션 컨트롤러를 `initState` 에서 생성).

## 검증
- `flutter analyze` 0건, `flutter test` 108개 통과(#862 와 합친 뒤). 라이트·다크 캡처 수정 전 22장, 수정 후 28장.

## 근본 원인 (확정)
요금제 이전 기준의 옵션 이름·위치가 결제 구조와 어긋나 있었다. 새 보기 모드 세트 재사용은 앱 쪽 분기 누락.

## 재발 방지
- "실전"이라는 말은 모의고사([[ISS-0463-sqld-mock-exam]])에만 쓴다.
- 이용권 관련 행은 계정·이용권 화면 한 곳에만 둔다.

## 알고 남긴 것
- 새 보기 모드를 켠 프로 회원은 문제마다 생성 대기가 생기고 AI 비용이 든다.

## 교훈
기능 이름은 사용자가 상상하는 동작과 실제 동작이 같아야 한다. 결제 구조가 바뀌면 옵션 위치·이름 조사표부터 다시 만든다.
