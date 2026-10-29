---
type: issue
id: ISS-0316
created: 2026-10-17
topics: [auth-member, security]
symptoms: [토큰 출처 검증 부족, 회원 중복, 탈퇴 연결 해제 누락, 계정 전환 이전 회원 데이터 노출, "[auth] 인증 실패", 리프레시 토큰 회원당 1개, 네이버 로그인 복귀 실패, taskAffinity]
root_cause: "토큰 발급 앱·제공자 대조 없음, (provider, provider_user_id) 유니크 제약 없음, 탈퇴 시 제공자 unlink 없음, 앱 회원 데이터가 현재 회원 기준으로 재구성되지 않음, RT 회원당 1개"
status: resolved
resolution: "[[ISS-0316-social-login-token-unlink-account-switch-report]]"
related: ["[[DEC-0143-server-side-social-unlink-on-withdraw]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]"]
source: "https://github.com/Twin-Fang/passQL/issues/516"
---

# ISS-0316: 소셜 로그인 토큰 검증 강화, 탈퇴 연결 해제, 계정 전환 시 이전 회원 데이터 노출

GitHub #516 (원본: 이슈 본문과 댓글).

## 증상
소셜 로그인 5종을 iOS 시뮬레이터에서 운영 서버로 실측하고 코드를 감사한 결과(로그인 자체는 모두 성공):
- 토큰 직접 로그인이 제공자 토큰이 passQL 앱에서 발급됐는지 확인하지 않는다. Firebase 토큰의 실제 제공자와 요청 제공자도 대조하지 않는다.
- 제공자 + 제공자 사용자 ID에 DB 유니크 제약이 없어 동시 첫 로그인 시 회원이 둘 생길 수 있다.
- 카카오·네이버·GitHub·Google은 탈퇴해도 제공자 연결이 남는다. 웹은 Apple revoke를 안 하고, 앱 Apple revoke는 Firebase 세션이 있을 때만 동작한다.
- 앱: 로그아웃 후 다른 계정으로 로그인하면 홈이 직전 회원의 닉네임·합격 준비도·진도를 먼저 보여준다. 로그아웃 순간 홈 데이터를 토큰 없이 재요청해 `[auth] 인증 실패` 경고 9건.
- 리프레시 토큰이 회원당 1개라 다른 기기 로그인 시 기존 기기가 로그아웃된다. 로그아웃은 받은 토큰과 저장된 토큰을 대조하지 않는다.
- 운영 허용 redirect에 로컬 주소, 로그 접두사 불일치, 방침은 이메일 수집이라 쓰지만 실제 미저장.
- Android 에뮬레이터(2026-10-18): 네이버 앱 없는 기기에서 네이버 로그인 후 앱으로 돌아오지 못함(D1), 실패가 취소로 처리됨(D2), 로그인 버튼 접근성 라벨 중복(D3).

## 재현 조건
앱에서 네이버 로그인 → 로그아웃 → Google 로그인 → 홈에 네이버 계정 닉네임·진도가 먼저 보임. 카카오 로그인 후 탈퇴 → 카카오 연결된 서비스에 passQL이 남음. iOS 18.3 시뮬레이터, passQL 1.12.2.

## 조사 기록
- 2026-10-18: Android E2E 결함 D1~D3 기록. D1 logcat에서 `NidOAuthCustomTabActivity`가 새 인스턴스로 생성됨.
- 2026-10-18: 서버·앱·웹 수정 배포, 후속으로 D1~D3 수정, iOS 1.19.0 심사 제출. 실기기 확인 항목은 GitHub #537로 분리하고 닫음.

## 근본 원인
위 frontmatter 요약. D1은 `MainActivity`의 `android:taskAffinity=""` 때문에 Chrome이 `naver3rdpartylogin://authorize`로 돌아올 때 기존 인스턴스를 찾지 못하고 새 태스크에 새 인스턴스를 만든 것(네이버 SDK aar manifest·바이트코드 근거).
