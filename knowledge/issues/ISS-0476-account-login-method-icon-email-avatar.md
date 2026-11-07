---
type: issue
id: ISS-0476
created: 2026-11-07
topics: [auth-member]
symptoms: ["로그인 방법 노란 글자 태그", "어떤 계정 이메일인지 모름", "프로필 머리 닉네임 펜 버튼", "닉네임 변경 진입점 두 곳", "프로필 사진 닉네임 첫 글자", "소셜 프로필 이미지 안 씀", "지난번 로그인 방법 표시 없음", profile_account_row.dart, login_provider_badge.dart, account_info_section.dart, MemberMeResponse]
root_cause: "서버가 소셜 로그인 응답의 이메일과 프로필 이미지를 저장하거나 내려주지 않았고, 앱은 제공자를 글자 태그로만 표시했으며 닉네임 변경 진입점이 두 곳이었다"
status: resolved
resolution: "[[ISS-0476-account-login-method-icon-email-avatar-report]]"
related: ["[[DEC-0276-account-provider-icon-email-avatar]]", "[[DEC-0263-pass-rows-on-account-screen-only]]", "[[DEC-0095-account-deletion-anonymize-soft-delete]]"]
source: "https://github.com/Twin-Fang/passQL/issues/908"
---

# ISS-0476: 계정 표시 정리: 로그인 방법 아이콘과 이메일, 펜 버튼 제거, 소셜 프로필 이미지, 최근 로그인 표시

GitHub #908 (https://github.com/Twin-Fang/passQL/issues/908). 직전 프로필 구조는 [[DEC-0263-pass-rows-on-account-screen-only]]. 원본 사본: `_sources/issues/ISS-0476-account-login-method-icon-email-avatar.md`(로컬).

## 증상
- 로그인 방법이 노란 글자 태그 "카카오" + "카카오 계정"으로만 보임. 어떤 계정(이메일)으로 들어왔는지 알 수 없음.
- 프로필 머리 닉네임 옆 펜 버튼으로 닉네임을 바로 바꿈. "관리"(계정 화면)에도 있어 진입점이 두 곳.
- 프로필 사진 자리에 닉네임 첫 글자만. 소셜 계정 프로필 이미지를 쓰지 않음.
- 로그아웃 뒤 다시 로그인할 때 지난번 방법 표시가 없음.

## 재현 조건
앱 프로필 탭 머리, 계정 이용권 화면, 로그인 화면.

## 조사 기록
- 2026-11-07: 서버 97514107, 앱과 웹 c72c0db3, 머리 줄 정리 986f144b. PR #914 머지.
- 2026-11-07 (후속, GitHub #908 열림): GitHub 는 콘솔 권한 설정이 없고 요청 범위로 정해진다. 프로필 사진은 `read:user` 로 이미 받고, 이메일은 공개한 사람만 받던 것을 `user:email` 범위 + `/user/emails` 대표·인증 이메일로 바꿈 (PR #937, 릴리스 #938, 범위 없는 옛 토큰이면 이메일만 빠짐). 남은 일: 카카오·네이버 개발자 콘솔 이메일·프로필 사진 동의(카카오는 보안 문자, 이메일은 비즈 앱 전환 필요), GitHub 로그인 실측(2단계 승인 시간 초과). 운영 회원 사진·이메일은 다시 로그인한 회원부터 채워짐.

## 근본 원인
서버가 소셜 로그인 응답의 이메일과 프로필 이미지를 저장하거나 응답에 넣지 않았다(회원 표 email 칸은 있었음). 앱은 제공자를 글자 태그로만 그렸다.
