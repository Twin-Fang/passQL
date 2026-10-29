---
type: cluster
topic: auth-member
created: 2026-10-29
members: 50
status: active
related: []
---

# 클러스터: auth-member

## 이 주제는
로그인·회원가입·탈퇴·온보딩·프로필

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 13개, 열린 이슈 2개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0012-nickname-via-suh-random-engine]] — 닉네임은 자체 단어 테이블 대신 `suh-random-engine` 라이브러리로 생성
- [[DEC-0080-firebase-oauth-own-jwt-no-anonymous]] — 소셜 로그인 토큰을 서버가 검증해 자체 JWT(AT 1h + RT 14d, Redis)를 발급하고, 익명 회원은 없앤다
- [[DEC-0095-account-deletion-anonymize-soft-delete]] — 회원 탈퇴는 식별 정보 즉시 제거 + 닉네임 익명화 + 소프트 삭제, 재로그인은 새 회원
- [[DEC-0112-web-app-core-feature-parity]] — 웹(React)·앱(Flutter) 투트랙 유지, 화면 1:1이 아니라 핵심 기능 동등성을 맞춘다
- [[DEC-0126-suspended-member-common-filter]] — 제재 회원 차단은 JWT 인증 뒤 공통 필터 한 곳에서, 인증·메타·탈퇴 요청은 예외
- [[DEC-0143-server-side-social-unlink-on-withdraw]] — 탈퇴 시 소셜 제공자 연결 해제는 서버가 하고, GitHub·네이버 토큰은 암호화 보관한다
- [[DEC-0144-per-device-refresh-token-reuse-revoke]] — refresh token은 기기별(`jti`)로 저장하고, 이미 회전된 토큰이 다시 오면 그 회원 세션을 전부 폐기한다
- [[DEC-0152-delete-photos-on-withdraw-keep-posts]] — 탈퇴 시 커뮤니티 글은 닉네임 익명화로 남기고, 사진은 저장소에서 지운다
- [[DEC-0171-four-tabs-merge-stats-my-profile]] — 하단 탭을 홈 / 문제 / 토론 / 내 프로필 4개로 — 기록과 MY를 `내 프로필`로 합치고 설정은 톱니바퀴로 여는 push 화면
- [[DEC-0180-social-login-disabled-opacity-only]] — 소셜 로그인 버튼은 비활성일 때 회색으로 바꾸지 않고 투명도만 낮춘다 (브랜드 색 유지)
- [[DEC-0184-new-member-onboarding-to-first-question]] — 앱 온보딩은 신규 가입자에게만 계정당 한 번, 4장 뒤 오늘의 세트 첫 문제로 이어지고 알림 권한은 묻지 않는다
- [[DEC-0185-withdraw-fixed-confirm-phrase]] — 회원 탈퇴는 고정 문구 `탈퇴하기`를 입력해야 버튼이 활성화된다 (앱·웹 공통, 공통 확인창 옵션)

## 대체된 결정 (역사)
- [[DEC-0088-app-settings-tab-as-mypage]] → null

## 관련 이슈
- [[ISS-0312-kakao-naver-github-apple-login]] (open, GitHub #509) — 카카오, 네이버, GitHub, Apple 로그인 지원
- [[ISS-0398-per-type-notification-preferences]] (open, GitHub #653) — 알림 종류별 수신 설정 (앱 설정 화면 + 서버 저장)
- [[ISS-0009-member-domain-module-entity]] (resolved, GitHub #6) — Member 도메인 모듈 신규 생성 및 확장 가능한 Entity 설계
- [[ISS-0025-admin-member-management]] (resolved, GitHub #33) — 관리자 회원 관리 페이지
- [[ISS-0146-oauth-jwt-auth-system]] (resolved, GitHub #271) — 서버에 인증이 전혀 없고 익명 가입만 가능
- [[ISS-0147-firebase-project-and-secrets]] (resolved, GitHub #272) — Firebase 서비스 계정·Secret 미등록으로 서버 기동 실패
- [[ISS-0148-web-login-multi-oauth-buttons]] (resolved, GitHub #274) — 웹 로그인 페이지에 Google 외 OAuth 버튼이 없음
- [[ISS-0150-tailwind4-spacing-namespace-login-layout]] (resolved, GitHub #277) — Tailwind 4 `@theme --spacing-*` 충돌로 로그인 페이지 레이아웃 파괴
- [[ISS-0151-actions-echo-corrupts-firebase-json]] (resolved, GitHub #280) — GitHub Actions `echo`가 Firebase JSON을 손상시켜 서버가 뜨지 않음
- [[ISS-0152-legal-domain-terms-modal]] (resolved, GitHub #283) — 로그인 화면에서 약관 내용을 볼 수 없고 약관이 시스템 설정에 섞여 있음
- [[ISS-0154-direct-nickname-change]] (resolved, GitHub #287) — 닉네임을 직접 입력해 바꿀 수 없음
- [[ISS-0165-settings-logout-button-ux]] (resolved, GitHub #308) — 설정 페이지 로그아웃 버튼 UX 개선
- [[ISS-0172-app-server-jwt-google-apple-login]] (resolved, GitHub #327) — 앱 서버 JWT 인증 전환 (Google/Apple 로그인)
- [[ISS-0173-app-api-client-server-alignment]] (resolved, GitHub #328) — 앱 API 클라이언트 서버 현행화 (memberUuid 제거, 추천 POST)
- [[ISS-0174-app-wrong-notes-nickname-choice-mode]] (resolved, GitHub #329) — 앱 마이페이지 오답 목록, 닉네임 변경, 선택지 생성 모드
- [[ISS-0185-member-account-deletion]] (resolved, GitHub #340) — 회원 탈퇴(계정 삭제) 기능 구현
- [[ISS-0186-ios-app-review-compliance-check]] (resolved, GitHub #341) — iOS 앱 심사 정책 준수 점검 및 보완
- [[ISS-0188-app-sse-parse-login-dead-ends]] (resolved, GitHub #343) — 출시 전 리뷰에서 확인된 SSE 파싱, 로그인 유지, 막다른 화면 문제
- [[ISS-0193-login-settings-redesign-wrong-notes]] (resolved, GitHub #348) — 로그인·설정 화면 디자인 개선 및 오답 노트 화면 분리
- [[ISS-0211-nickname-sheet-infinite-width]] (resolved, GitHub #366) — 닉네임 변경 시트가 열리지 않음 — 중복확인 버튼 무한 폭 제약으로 레이아웃 예외
- [[ISS-0222-withdrawn-member-in-daily-leaderboard]] (resolved, GitHub #377) — 탈퇴한 회원이 오늘의 순위에 `탈퇴회원_xxxx`로 계속 노출됨
- [[ISS-0231-web-invalid-access-token-stuck-home]] (resolved, GitHub #398) — 액세스 토큰만 무효일 때 로그인으로 이동하지 않고 홈에 갇힘 (웹)
- [[ISS-0234-web-login-contrast-layout-shift]] (resolved, GitHub #401) — 로그인 화면 약관 링크·오류 문구 대비 부족과 오류 표시 시 레이아웃 밀림 (웹)
- [[ISS-0247-web-withdrawal-app-release-banner]] (resolved, GitHub #433) — 웹 회원 탈퇴 부재 + 앱 출시 안내 자리 없음 (웹·앱 핵심 기능 맞추기)
- [[ISS-0257-ios-review-reject-apple-sign-in]] (resolved, GitHub #451) — iOS 심사 리젝 — Apple 로그인 후 에러 (Firebase Apple 공급자 미등록)
- [[ISS-0276-suspended-member-blocked-only-in-getme]] (resolved, GitHub #470) — 제재 회원 차단이 getMe에서만 동작
- [[ISS-0290-app-settings-errors-suspension-notice]] (resolved, GitHub #484) — 앱 설정 화면 오류 처리 누락과 제재 회원 안내 부재
- [[ISS-0316-social-login-token-unlink-account-switch]] (resolved, GitHub #516) — 소셜 로그인 토큰 검증 강화, 탈퇴 연결 해제, 계정 전환 시 이전 회원 데이터 노출
- [[ISS-0329-android-naver-login-device-check]] (resolved, GitHub #537) — Android 네이버 로그인 실기기 확인과 네이버 검수 결과 반영
- [[ISS-0335-withdraw-apple-reauth-spinner-stuck]] (resolved, GitHub #547) — 회원 탈퇴 중 Apple 재인증 취소·실패 시 로딩 스피너가 해제되지 않음
- [[ISS-0359-nickname-regenerate-cooldown-bypass]] (resolved, GitHub #579) — 닉네임 랜덤 재생성에 3일 쿨다운 적용과 새로고침 버튼 안내 보강
- [[ISS-0381-admin-member-list-detail-tools]] (resolved, GitHub #626) — 관리자 회원 목록·상세에 정렬·검색·메모·일괄 처리가 없음
- [[ISS-0402-login-buttons-bottom-disabled-state]] (resolved, GitHub #668) — 로그인 화면 버튼 하단 배치와 로그인 중 버튼 비활성 표시
- [[ISS-0404-remove-login-logout-transition]] (resolved, GitHub #672) — 로그인·로그아웃 화면 전환 애니메이션 제거
- [[ISS-0407-new-member-onboarding-screens]] (resolved, GitHub #683) — 신규 가입자 온보딩 화면 추가 (앱)
- [[ISS-0408-withdraw-confirm-phrase-input]] (resolved, GitHub #685) — 탈퇴 시 확인 문구 입력 추가
- [[ISS-0409-radius-tokens-nickname-edit-cleanup]] (resolved, GitHub #687) — 모서리, 닉네임 편집 정리 (앱)
