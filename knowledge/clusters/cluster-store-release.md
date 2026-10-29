---
type: cluster
topic: store-release
created: 2026-10-29
members: 50
status: active
related: []
---

# 클러스터: store-release

## 이 주제는
스토어 심사·출시·스토어 문구·법적 고지

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 15개, 열린 이슈 5개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0065-source-available-license-no-commercial]] — 저장소 라이선스를 MIT에서 자체 Source-Available License 1.0으로 — 상업적 이용 영구 금지
- [[DEC-0082-legal-table-separate-from-app-setting]] — 약관(이용약관·개인정보처리방침)은 `AppSetting`이 아닌 독립 `legal` 테이블에서 관리한다
- [[DEC-0095-account-deletion-anonymize-soft-delete]] — 회원 탈퇴는 식별 정보 즉시 제거 + 닉네임 익명화 + 소프트 삭제, 재로그인은 새 회원
- [[DEC-0096-app-id-com-coldredrice-passql]] — Android·iOS 앱 ID를 `com.coldredrice.passql` 하나로 쓴다
- [[DEC-0097-release-signing-key-properties]] — Android 릴리스 서명은 `key.properties` 기반, 키스토어·비밀번호는 저장소 밖(로컬·CI 시크릿)
- [[DEC-0105-legal-docs-single-source-server-db]] — 약관·개인정보처리방침 원본은 서버 DB(관리자 `/admin/legal`) 하나
- [[DEC-0112-web-app-core-feature-parity]] — 웹(React)·앱(Flutter) 투트랙 유지, 화면 1:1이 아니라 핵심 기능 동등성을 맞춘다
- [[DEC-0115-android-play-build-from-main]] — Android Play 워크플로의 빌드 기준을 `deploy`에서 `main`으로 바꾼다 (iOS와 동일)
- [[DEC-0119-legal-urls-on-github-pages]] — 약관 공개 URL은 GitHub Pages(twin-fang.github.io/passQL)를 남기고 웹 `/legal/*`은 그쪽으로 리다이렉트
- [[DEC-0132-push-permission-pre-prompt-sheet]] — 알림 권한은 앱 안내 시트 뒤 "알림 받기"를 눌렀을 때만 시스템 창으로 요청, "나중에"는 7일간 다시 묻지 않음
- [[DEC-0139-intro-site-generated-from-src]] — 소개 사이트(gh-pages)는 `_src/` 생성 스크립트로만 만들고 HTML을 손으로 고치지 않는다
- [[DEC-0140-no-spa-prerender-web-app]] — 웹 앱은 SPA 사전 렌더링을 하지 않고 `index.html` 정적 태그로만 검색 노출을 맞춘다
- [[DEC-0169-store-listing-korean-only]] — 스토어 홍보 이미지·설명은 한국어만 만들고, 문구는 `scenes.json`에서 도구로 렌더링한다
- [[DEC-0176-license-holder-kollylab]] — `LICENSE` 저작권자·Licensor는 `KOLLYLAB (콜리랩)`, 문의 연락처는 운영자 이메일 하나, 사업자 식별 정보는 공개 레포에 넣지 않는다
- [[DEC-0201-play-promote-closed-testing-default-false]] — Play 수동 배포의 비공개 테스트(alpha) 승급은 기본 끔 — 필요할 때만 체크해서 승급

## 대체된 결정 (역사)
- 없음

## 관련 이슈
- [[ISS-0355-store-review-status-tracking-issue]] (open, GitHub #570) — 스토어 심사 상태 자동 알림 (구독용, 닫지 않음)
- [[ISS-0361-billing-switch-final-checks]] (open, GitHub #596) — 결제 스위치 켜기 전 최종 점검 (실구매·심사·최소 버전)
- [[ISS-0379-admin-settings-terms-history-restore]] (open, GitHub #624) — 관리자 설정·약관에 변경 이력·복원·검증이 없음
- [[ISS-0388-remove-question-count-from-store-copy]] (open, GitHub #636) — README·스토어 문구·홍보 이미지에 문제 수(300문제 이상)가 남아 있음
- [[ISS-0400-business-info-display-kollylab]] (open, GitHub #658) — 앱·웹·사이트 사업자 정보 표기 (콜리랩)
- [[ISS-0099-license-ban-commercial-use]] (resolved, GitHub #180) — LICENSE 상업적 이용 금지 정책 수립
- [[ISS-0152-legal-domain-terms-modal]] (resolved, GitHub #283) — 로그인 화면에서 약관 내용을 볼 수 없고 약관이 시스템 설정에 섞여 있음
- [[ISS-0184-production-launch-criteria]] (resolved, GitHub #339) — 정식 서비스(production) 출시 기준 정립
- [[ISS-0185-member-account-deletion]] (resolved, GitHub #340) — 회원 탈퇴(계정 삭제) 기능 구현
- [[ISS-0186-ios-app-review-compliance-check]] (resolved, GitHub #341) — iOS 앱 심사 정책 준수 점검 및 보완
- [[ISS-0189-unify-app-id-asc-bundle]] (resolved, GitHub #344) — 앱 ID를 App Store Connect 등록값(`com.coldredrice.passql`)으로 통일
- [[ISS-0190-android-release-signing-key]] (resolved, GitHub #345) — Android 릴리스 서명 키 구성 (Play Store 업로드 준비)
- [[ISS-0191-store-public-legal-pages-metadata]] (resolved, GitHub #346) — 스토어 등록용 공개 약관 페이지와 심사 제출 정보 정리
- [[ISS-0192-play-closed-test-and-ios-review-submit]] (resolved, GitHub #347) — 스토어 출시 — Play 비공개 테스트 및 iOS 심사 제출
- [[ISS-0195-legal-text-escaped-newlines]] (resolved, GitHub #350) — 약관 화면에 `\n` 글자가 그대로 보이고 조항이 한 덩어리로 표시됨
- [[ISS-0197-app-store-review-submission]] (resolved, GitHub #352) — App Store 심사 제출
- [[ISS-0198-google-play-closed-testing]] (resolved, GitHub #353) — Google Play 비공개 테스트 진행
- [[ISS-0204-github-pages-intro-legal-site]] (resolved, GitHub #359) — passQL 서비스 소개·이용약관·개인정보처리방침 GitHub Pages 페이지
- [[ISS-0236-legal-docs-three-sources-mismatch]] (resolved, GitHub #403) — 약관·개인정보처리방침 원본 3곳 불일치와 탈퇴 안내 경로 불일치
- [[ISS-0237-gh-pages-mobile-layout-meta]] (resolved, GitHub #404) — 소개 페이지(gh-pages) 모바일 레이아웃 깨짐과 메타 누락
- [[ISS-0247-web-withdrawal-app-release-banner]] (resolved, GitHub #433) — 웹 회원 탈퇴 부재 + 앱 출시 안내 자리 없음 (웹·앱 핵심 기능 맞추기)
- [[ISS-0254-projectops-4-40-play-closed-testing]] (resolved, GitHub #448) — Android 배포가 내부 테스트까지만 올라가고 비공개 테스트가 0.0.220에 머묾
- [[ISS-0257-ios-review-reject-apple-sign-in]] (resolved, GitHub #451) — iOS 심사 리젝 — Apple 로그인 후 에러 (Firebase Apple 공급자 미등록)
- [[ISS-0263-replace-pages-store-screenshots]] (resolved, GitHub #457) — 새 디자인 기준으로 GitHub Pages·스토어 스크린샷 교체
- [[ISS-0268-web-brand-color-token-lint]] (resolved, GitHub #462) — 웹 브랜드 색이 앱과 다르고 hex·인라인 style이 흩어짐, 약관 사본
- [[ISS-0294-oss-license-menu-feedback-device-info]] (resolved, GitHub #488) — 앱 설정에 오픈소스 라이선스 메뉴가 없고 의견 보내기에 기기 정보가 없음
- [[ISS-0310-sqld-seo-intro-site-revamp]] (resolved, GitHub #505) — SQLD·SQLP 검색 노출과 소개 사이트 개편
- [[ISS-0327-web-download-banner-store-badges]] (resolved, GitHub #531) — 웹 앱 다운로드 배너를 공식 스토어 배지로 재디자인
- [[ISS-0353-android-production-access-not-granted]] (resolved, GitHub #568) — Android 프로덕션 승급 실패 — Play 계정 프로덕션 액세스 미승인
- [[ISS-0354-store-review-status-notifications]] (resolved, GitHub #569) — 스토어 심사 결과를 개인 메일로 받기 — 자동 상태 알림과 계정 알림 설정
- [[ISS-0360-store-promo-images-descriptions]] (resolved, GitHub #586) — 스토어 홍보 이미지·설명 문구 새로 만들기
- [[ISS-0389-license-holder-kollylab]] (resolved, GitHub #638) — LICENSE 저작권자·Licensor가 해커톤 팀 이름으로 남아 있고 문의 연락처가 정리되지 않음
- [[ISS-0397-promo-site-overhaul-operator-notice]] (resolved, GitHub #650) — 홍보 페이지(github.io) 전체 재정비와 약관 운영자 표기
- [[ISS-0401-hide-question-counts-exam-trend]] (resolved, GitHub #660) — 최신 경향 화면에서 문제 수·표본 크기 숨기기
- [[ISS-0422-play-closed-testing-promote-default-off]] (resolved, GitHub #729) — Play 수동 배포 비공개 테스트 승급 기본값 끄기
