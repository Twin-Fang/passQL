---
type: completion-report
id: ISS-0290
created: 2026-10-15
topics: [auth-member]
status: resolved
resolves: "[[ISS-0290-app-settings-errors-suspension-notice]]"
related: ["[[ISS-0276-suspended-member-blocked-only-in-getme]]", "[[DEC-0126-suspended-member-common-filter]]"]
source: "https://github.com/Twin-Fang/passQL/issues/484"
---

# ISS-0290 완료 리포트: 재생성 실패 복원·토스트, `appVersionProvider` 분리, `MemberSuspensionInterceptor`

GitHub #484 구현 보고서 댓글 기준 (1차 통합본, 서버 GitHub #470과 함께 배포).

## 해결 방법
- 재생성 실패 시 이전 닉네임 복원과 토스트.
- 버전은 `appVersionProvider`(PackageInfo)로 분리.
- `MemberSuspensionInterceptor` + `MemberSuspensionSignal`(`SessionExpirySignal`과 같은 방식): 403 수신 시 안내 문구 저장 > 로그아웃 > 기기 세션·소셜 로그인 정리(동시 403은 1회만).
- 로그인 화면이 남겨 둔 안내 문구를 한 번 표시.
- 검증: 인터셉터·제재 로그아웃·로그인 안내·설정 스모크 테스트 추가, `flutter analyze` 경고 0, `flutter test` 271개 통과.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본): 서버는 `/api/auth/**`(재발급)를 차단하지 않으므로 제재 회원은 재발급 후 getMe의 403으로 안내를 받는다.

## 교훈
(원본에 없음, 볼트 정리) 서버 데이터와 무관한 값(앱 버전)을 서버 응답 provider에 묶으면 네트워크 실패 때 함께 사라진다.
