---
type: issue
id: ISS-0481
created: 2026-11-07
topics: [auth-member]
symptoms: ["앱 설정 하단 회원 ID UUID 36자", "웹 회원 번호와 앱 표시 다름", "memberCode 안 씀", settings_footer.dart, SettingsFooter]
root_cause: "서버 /members/me 가 memberCode 를 내려 주고 앱 모델에도 있었지만, 앱 설정 하단은 memberUuid 를 그대로 보여 줬다"
status: resolved
resolution: "[[ISS-0481-app-settings-member-code-footer-report]]"
related: ["[[ISS-0476-account-login-method-icon-email-avatar]]", "[[ISS-0482-admin-search-member-code]]"]
source: "_sources/issues/ISS-0481-app-settings-member-code-footer.md"
---

# ISS-0481: 앱 설정 하단 회원 ID 를 웹과 같은 회원 번호로

GitHub #926 (https://github.com/Twin-Fang/passQL/issues/926).

## 증상
- 웹 설정 `내 계정`: 회원 번호 `PQL-` + UUID 앞 8자리 ("문의할 때 회원 번호를 알려 주세요", #908).
- 앱 설정 하단: 회원 ID 로 UUID 36자 전체, 눌러서 복사.
- 문의할 때 웹과 앱에서 서로 다른 값을 보게 된다.

## 재현 조건
앱 설정 화면 맨 아래 (운영 1.90 실측, 2026-11-07).

## 조사 기록
- 2026-11-07: 운영 1.90 앱·웹 설정 캡처 비교로 발견. 서버 응답과 앱 모델에 `memberCode` 가 이미 있음 확인.
- 2026-11-07: `SettingsFooter` 가 회원 번호 우선 표시·복사, 없으면 UUID (ef424c11, PR #928).

## 근본 원인
앱 설정 하단이 `memberCode` 대신 `memberUuid` 를 썼다.
