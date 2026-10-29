---
type: issue
id: ISS-0185
created: 2026-10-06
topics: [auth-member, store-release]
symptoms: ["회원 탈퇴 없음", "계정 삭제", "iOS 심사 필수", "DELETE /api/members/me", "탈퇴회원_", "개인정보 파기"]
root_cause: "회원 탈퇴 기능이 서버와 앱 모두 없음"
status: resolved
resolution: "[[ISS-0185-member-account-deletion-report]]"
related: ["[[DEC-0095-account-deletion-anonymize-soft-delete]]", "[[ISS-0184-production-launch-criteria]]"]
source: "https://github.com/Twin-Fang/passQL/issues/340"
---

# ISS-0185: 회원 탈퇴(계정 삭제) 기능 구현

GitHub #340 (원본: 이슈 본문과 완료 댓글).

## 증상
(현재 문제점) 회원 탈퇴가 서버·앱 모두 없다. 소셜 로그인 앱은 앱 안에서 계정 삭제가 가능해야 하고(iOS 심사 필수) 개인정보 파기 요구에도 해당한다(GitHub #339 출시 위험 4번).

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-06 계획: 서버 `DELETE /api/members/me`(이메일·소셜 식별자 즉시 비움, 닉네임 익명화, 소프트 삭제, 리프레시 토큰 삭제, 같은 소셜 계정 재로그인 시 새 회원), 앱 설정에 확인 단계 있는 "회원 탈퇴".
- 2026-10-06: 이 모듈의 기존 `SpringBootTest` 테스트는 `PassqlApplication`이 다른 모듈에 있어 컴파일되지 않는 기존 문제가 있음(이번 변경과 무관). 신규 테스트는 웹 모듈에 둠.

## 근본 원인
해당 없음 (기능 추가).
