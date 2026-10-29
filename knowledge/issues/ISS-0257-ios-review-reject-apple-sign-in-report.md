---
type: completion-report
id: ISS-0257
created: 2026-10-16
topics: [auth-member, store-release]
status: resolved
resolves: "[[ISS-0257-ios-review-reject-apple-sign-in]]"
related: ["[[ISS-0258-github-secret-synology-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/451"
---

# ISS-0257 완료 리포트: Firebase Apple 공급자 등록 후 재제출, App Store 1.0 출시

GitHub #451 수정 완료 댓글(2026-10-15)과 완료 처리·심사 통과 댓글(2026-10-16) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
코드 변경 없이 Firebase 설정과 Apple Developer 설정만 고쳤다(앱·서버 재배포 불필요).
1. Firebase Authentication: 서비스 계정으로 Identity Toolkit Admin API(`defaultSupportedIdpConfigs/apple.com`)를 호출해 Apple 공급자 등록(enabled `true`, bundleIds `com.coldredrice.passql`, `codeFlowConfig` 팀·키 식별자와 개인키 — 값은 볼트에 옮기지 않음). `codeFlowConfig`는 탈퇴 시 Apple 토큰을 폐기하는 `revokeTokenWithAuthorizationCode`(App Store 5.1.1(v))에 필요. 설정 후 재조회로 반영 확인.
2. Apple Developer: Sign in with Apple 키 `PASSQL SIWA` 발급(Primary App ID `com.coldredrice.passql`). `.p8` 원본은 다시 내려받을 수 없어 로컬에 따로 보관(레포에 커밋 안 함).
3. 빌드를 **0.8.0 (87839013)** 으로 바꿔 원인·조치를 회신하고 재제출.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본: "Firebase 콘솔 설정은 코드에 드러나지 않습니다. 앞으로 Apple 로그인이 실패하면 Firebase Authentication → 로그인 방법에서 Apple 공급자가 켜져 있는지부터 확인합니다."
- 결과: App Store 1.0 출시 `2026-10-16T00:42:17Z`(#352), 앱 버전 `1.0` 상태 **READY_FOR_SALE**.
- 남은 확인(원본): 실기기에서 Apple 로그인·Apple 계정 탈퇴가 끝까지 되는지는 직접 확인하지 않음.
- 출시 후 TestFlight 업로드가 `0.16.0`은 이미 닫힌 버전이라는 사전 점검(`ios_release.py precheck-version`)에 걸려 `version.yml`을 `1.1.0`으로 올림(App Store 1.0보다 높은 버전만 새 빌드로 올라감). 이후 앱 버전은 1.x.

## 교훈
원본 재발 방지 문장과 같음: 소셜 로그인 실패 시 콘솔의 공급자 활성화 여부부터 본다.
