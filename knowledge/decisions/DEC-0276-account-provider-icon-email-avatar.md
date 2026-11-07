---
type: decision
id: DEC-0276
created: 2026-11-07
reviewed: null
topics: [auth-member, design-system, billing]
status: active
supersedes: DEC-0263
superseded_by: null
related: ["[[ISS-0476-account-login-method-icon-email-avatar]]", "[[ISS-0476-account-login-method-icon-email-avatar-report]]", "[[DEC-0263-pass-rows-on-account-screen-only]]", "[[DEC-0095-account-deletion-anonymize-soft-delete]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0207-pass-ticket-upright-float-shadow]]", "[[DEC-0212-keep-benefit-icon-row-in-ticket]]"]
---

# DEC-0276: 닉네임 변경은 계정 화면 "관리"에서만 하고(프로필 머리 펜 없음), 로그인 방법은 제공자 아이콘 + 이메일로, 소셜 프로필 이미지를 저장해 띄우며, 로그인 화면에 최근 로그인 배지를 둔다

## 문제 정의 (Context)
[[DEC-0263-pass-rows-on-account-screen-only]]는 프로필 닉네임 줄에 연필 아이콘을 두고 계정 화면에서도 닉네임을 바꾸게 했다. 진입점이 두 곳이었고, 로그인 방법은 노란 글자 태그뿐이라 어떤 계정(이메일)인지 알 수 없었으며, 프로필 사진은 첫 글자뿐이었다 (GitHub #908, [[ISS-0476-account-login-method-icon-email-avatar]]).

## 결정 (Decision)
- **닉네임:** 프로필 머리 펜 버튼을 없애고, 닉네임 변경은 계정 화면 "관리"에서만. 프로필 머리 줄 전체가 "관리" 진입이며 줄은 `[제공자 아이콘] 2026.10.16 가입` 모양.
- **로그인 방법:** 글자 태그 대신 제공자 아이콘(카카오, 네이버, Google, Apple, GitHub) + 그 계정 이메일. 이메일이 없거나 Apple 가림 주소면 제공자 이름. 이메일은 본인 화면에만.
- **프로필 이미지:** 서버가 소셜 로그인 응답의 이메일과 프로필 이미지를 새 가입과 이후 로그인 때 저장한다(바뀐 값만, 이메일 없으면 기존 유지, http는 https로, 카카오 기본 이미지는 저장 안 함, 탈퇴 시 삭제). 앱과 웹은 원형 사진, 없거나 실패하면 첫 글자.
- **최근 로그인:** 마지막으로 성공한 제공자 버튼에 "최근 로그인" 배지. 기기에 저장, 로그아웃해도 유지, 탈퇴하면 삭제.
- **웹:** 계정 화면이 없어 설정 맨 위 "내 계정" 묶음에 같은 표시.
- **DEC-0263에서 그대로인 것:** 구매 내역, 구매 복원, 프로모션 코드 행은 계정, 이용권 화면(`/account`) 한 곳, 프로필 이용권 자리에는 "이용권 관리" 한 줄. 첫 구간 순서(계정 줄 > 내 정답률 큰 숫자 > 이용권 자리), 계정 줄은 결제 스위치와 무관하게 항상 보임. 무료 이용권 자리(오늘 남은 문제, 게이지, 보너스 3칸 [[DEC-0239-free-daily-limit-bonus-three-kinds]]), 프로 탑승권 카드, 결제 표시 꺼짐이면 이용권 자리 없음([[DEC-0005-ship-with-billing-switch-off]]), 시트 탑승권([[DEC-0207-pass-ticket-upright-float-shadow]], [[DEC-0212-keep-benefit-icon-row-in-ticket]]).

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문이 아이콘 + 이메일, 펜 제거, 소셜 이미지, 최근 로그인 표시를 처음부터 제시. 머리 줄의 "로그인" 글자는 아이콘이 로그인 방법을 뜻해 겹쳐서 뺐다고 커밋 986f144b 에 적힘.)

## 결과 (Consequences)
**긍정**
- 닉네임 변경 진입점이 하나가 되고, 어떤 계정으로 들어왔는지 바로 보인다.

**부정 / 조건**
- 기존 회원은 다음 로그인부터 이메일과 사진이 채워진다.
- 제공자 콘솔의 이메일, 프로필 사진 동의 항목이 꺼져 있으면 값이 들어오지 않는다. 운영 개인정보 처리방침 수집 항목 확인이 남았다 (리포트 「남은 일」).

## 영향 범위 (Scope)
서버 `SocialProfile`, `SocialProfileSyncService`, 소셜 로그인 전략 5종, `Member`(`profile_image_url`, Flyway `V1_83_0_8`), `MemberMeResponse`, API 계약. 앱 `profile_account_row.dart`, `account_info_section.dart`, `login_provider_*`, `passql_avatar.dart`, `social_login_button.dart`. 웹 `AccountInfoSection.tsx`, `ProfileAvatar.tsx`, `Login.tsx`, `Settings.tsx`, `recentLoginProviderStore.ts`.

## 출처 (References)
- GitHub #908 이슈 본문, 구현 확인 댓글, 리포트 댓글 (2026-11-07), PR #914
- 대체 대상: [[DEC-0263-pass-rows-on-account-screen-only]] (닉네임 연필 아이콘 부분 변경)
- W4 충돌 검사: [[DEC-0095-account-deletion-anonymize-soft-delete]](탈퇴 시 이메일 즉시 제거)와 충돌 없음, 이미지도 탈퇴 시 삭제
