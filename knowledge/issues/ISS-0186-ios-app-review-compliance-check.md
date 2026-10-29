---
type: issue
id: ISS-0186
created: 2026-10-06
topics: [store-release, auth-member]
symptoms: [App Store 심사 거절 위험, "Passql App", ITSAppUsesNonExemptEncryption, 약관 열람 불가, Apple 토큰 폐기 없음, 플레이스홀더 아이콘]
root_cause: "iOS 심사 정책(5.1.1, 5.1.1(v)) 대응 항목이 앱에 빠져 있었다 — 표시 이름, 암호화 신고 키, 앱 내 약관 열람, Apple 탈퇴 토큰 폐기, 미사용 권한 패키지"
status: resolved
resolution: "[[ISS-0186-ios-app-review-compliance-check-report]]"
related: ["[[ISS-0192-play-closed-test-and-ios-review-submit]]", "[[ISS-0189-unify-app-id-asc-bundle]]"]
source: "https://github.com/Twin-Fang/passQL/issues/341"
---

# ISS-0186: iOS 앱 심사 정책 준수 점검 및 보완

GitHub #341 (원본: 이슈 본문과 댓글).

## 증상
App Store Review Guidelines 기준으로 거절될 수 있는 항목:
- 앱 표시 이름이 `Passql App`
- 암호화 수출 규정 신고 키(`ITSAppUsesNonExemptEncryption`)가 없어 업로드마다 질문이 나옴
- 앱 안에서 이용약관·개인정보처리방침을 볼 수 없음 (5.1.1, 서버에는 내용이 있음)
- 사용하지 않는 권한 관련 패키지(알림, 진동 등) 포함
- Sign in with Apple 사용자 회원 탈퇴 시 Apple 토큰 폐기 없음 (5.1.1(v))

## 재현 조건
해당 없음 (출시 전 정책 점검).

## 조사 기록
- 2026-10-06: 코드로 처리 가능한 항목 완료(커밋 `45fc466`, `962f226`). 기본 앱 아이콘과 시작 화면이 플레이스홀더라는 거절 사유도 추가로 확인.
- 2026-10-06: App Store Connect에서 번들 ID `kr.suhsaechan.passql`로 조회한 앱이 0개(Xcode 로그 `data: []`) — 만들어 둔 앱(6762165005)의 번들 ID 확인 필요로 막힘 (후속 GitHub #344).
- 2026-10-07: 점검을 마치고 App Store 심사에 제출(GitHub #347), 상태 `WAITING_FOR_REVIEW`.

## 근본 원인
심사 정책 대응 항목이 앱에 구현·설정되지 않은 상태였다. 원인 배경은 원본에 적혀 있지 않다.
