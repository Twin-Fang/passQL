---
type: completion-report
id: ISS-0185
created: 2026-10-06
topics: [auth-member, store-release]
status: resolved
resolves: "[[ISS-0185-member-account-deletion]]"
related: ["[[DEC-0095-account-deletion-anonymize-soft-delete]]"]
source: "https://github.com/Twin-Fang/passQL/issues/340"
---

# ISS-0185 완료 리포트: `DELETE /api/members/me`(204)와 앱 설정 "회원 탈퇴"

GitHub #340 완료 댓글(2026-10-06, 서버 `2014f62`, 앱 `1f00667`, 운영 배포 완료) 기준.

## 해결 방법
- 서버 `DELETE /api/members/me`(204): 이메일·소셜 식별자 제거, 닉네임 익명화(`탈퇴회원_xxxx`), 소프트 삭제, 리프레시 토큰 삭제. 같은 소셜 계정으로 다시 로그인하면 새 회원으로 가입.
- 앱 설정 "회원 탈퇴"(확인 대화상자). 서버 요청이 실패하면 계정과 세션을 그대로 두고 사유 안내.
- 운영 확인: 토큰 없이 호출 시 401. 검증: 서버 단위 테스트 3개, 앱 테스트 128개.

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
기존 모듈 `SpringBootTest` 컴파일 문제는 이번 변경과 무관한 기존 문제로 남김, 신규 테스트는 웹 모듈.

## 교훈
원본에 적혀 있지 않다.
