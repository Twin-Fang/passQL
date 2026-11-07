---
type: completion-report
id: ISS-0476
created: 2026-11-07
topics: [auth-member]
status: resolved
resolves: "[[ISS-0476-account-login-method-icon-email-avatar]]"
related: ["[[DEC-0276-account-provider-icon-email-avatar]]", "[[DEC-0095-account-deletion-anonymize-soft-delete]]"]
source: "https://github.com/Twin-Fang/passQL/issues/908"
---

# ISS-0476 완료 리포트: 소셜 이메일과 사진 저장(profile_image_url), 제공자 아이콘 + 이메일, 펜 제거, 아바타, 최근 로그인 배지

GitHub #908 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/908#issuecomment-6702224769). PR #914 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0476-account-login-method-icon-email-avatar-report.md`(로컬).

## 해결 방법
- 서버: `SocialProfile`, `SocialProfileSyncService`, 소셜 로그인 5종 전략에서 이메일과 프로필 이미지. 새 가입과 이후 로그인 때 바뀐 값만 저장, 이메일 없으면 기존 유지, http > https, 카카오 기본 이미지 저장 안 함. Flyway `V1_83_0_8__member_profile_image.sql`(회원 표 `profile_image_url`). 탈퇴 시 이미지도 삭제. 본인 정보 응답 `email`, `profileImageUrl`, API 계약과 웹 타입 갱신. 관리자 회원 상세 아바타.
- 앱: 제공자 아이콘 + 이메일(없거나 Apple 가림 주소면 제공자 이름, 긴 이메일 말줄임). 프로필 머리 펜 제거, 줄 전체가 "관리" 진입, 머리 줄 `[아이콘] 2026.10.16 가입`. `PassqlAvatar`(사진 원형, 실패면 첫 글자). 로그인 화면 "최근 로그인" 배지(기기 저장, 로그아웃 유지, 탈퇴 삭제).
- 웹: 같은 표시, 계정 화면이 없어 설정 맨 위에 "내 계정" 묶음.
- [[DEC-0276-account-provider-icon-email-avatar]].

## 검증
- 서버 `./gradlew build` 124개 실패 0, 앱 `flutter test` 128개, 웹 lint와 35개, `tsc` 통과, 코드 점검 새 위반 0.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 기존 회원은 다음 로그인부터 이메일과 사진이 채워진다.
- 이메일은 본인 화면에만. 다른 회원에게 보이는 응답에 넣을 때는 처리방침 수집 항목과 공개 범위를 다시 확인.
- 회원 표에 개인 정보 칸을 더하면 탈퇴 처리([[DEC-0095-account-deletion-anonymize-soft-delete]])에도 넣는다.

## 남은 일
- 사람, 콘솔: 카카오 동의 항목 "카카오계정(이메일)", "프로필 사진", 네이버 제공 정보 이메일, 프로필 사진 켜짐 확인. 운영 개인정보 처리방침 수집 항목 확인(레포 최초 문구에는 이메일, 프로필 사진(선택) 있음).
- 배포 뒤 실측은 후속 댓글.

## 교훈
소셜 제공자 값은 코드만으로 채워지지 않는다. 콘솔 동의 항목이 꺼져 있으면 빈 값이 오므로, 제공자 데이터를 새로 쓰는 기능은 콘솔 확인을 완료 조건에 넣어야 한다.
