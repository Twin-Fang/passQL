---
type: decision
id: DEC-0095
created: 2026-10-06
reviewed: null
topics: [auth-member, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0185-member-account-deletion]]", "[[ISS-0185-member-account-deletion-report]]", "[[DEC-0014-explicit-soft-delete-filter]]"]
---

# DEC-0095: 회원 탈퇴는 식별 정보 즉시 제거 + 닉네임 익명화 + 소프트 삭제, 재로그인은 새 회원

## 문제 정의 (Context)
소셜 로그인 앱은 앱 안 계정 삭제가 필요하고(iOS 심사 필수) 개인정보 파기 요구에도 해당하는데 탈퇴 기능이 없었다 (GitHub #340, #339 출시 위험 4번).

## 결정 (Decision)
서버 `DELETE /api/members/me`(204):
- 이메일과 소셜 식별자는 즉시 제거한다.
- 닉네임은 익명화한다(`탈퇴회원_xxxx`).
- 회원은 소프트 삭제하고 리프레시 토큰을 삭제한다.
- 같은 소셜 계정으로 다시 로그인하면 새 회원으로 가입한다.
앱은 설정에서 확인 대화상자를 거쳐 호출하고, 성공 시 기기 로그인 상태·사용자별 캐시를 지우고 로그인 화면으로 이동한다. 서버 요청 실패 시 계정·세션을 그대로 둔다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- iOS 심사 요건과 개인정보 파기 요구에 대응한다(원본 동기).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 회원 서비스·컨트롤러·API 문서(`DELETE /api/members/me`), 앱 API·상태 관리·설정 화면. 소프트 삭제 방식은 [[DEC-0014-explicit-soft-delete-filter]]의 `is_deleted` 필터를 따르는지 원본에 적혀 있지 않다.

## 출처 (References)
- GitHub #340 이슈 본문 "해결 방안", 완료 댓글(2026-10-06)
