---
type: completion-report
id: ISS-0186
created: 2026-10-06
topics: [store-release, auth-member]
status: resolved
resolves: "[[ISS-0186-ios-app-review-compliance-check]]"
related: ["[[ISS-0192-play-closed-test-and-ios-review-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/341"
---

# ISS-0186 완료 리포트: iOS 심사 정책 항목 보완 후 심사 제출

GitHub #341 완료 댓글 기준 (커밋 `45fc466`, `962f226`, 2026-10-06 / 제출 확인 2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 앱 표시 이름 `passQL`, `ITSAppUsesNonExemptEncryption=false`
- 앱 안 이용약관·개인정보처리방침 열람(로그인 화면 안내 문구, 설정 화면). 가입 전에도 열람 가능
- 회원 탈퇴 시 Apple 로그인 사용자 토큰 회수(재인증, 취소하면 탈퇴 중단)
- 사용하지 않는 패키지 11개 제거(알림, 진동, 공유 등 권한 관련 포함)
- 플레이스홀더 아이콘·시작 화면을 브랜드 색 `QL` 임시 아이콘으로 교체 (디자인 GitHub #317이 나오면 `app/assets/app_icon_1024.png`만 교체하고 `dart run flutter_launcher_icons`)
- 앱스토어용 서명 IPA 빌드 성공(34.5MB)
- iOS 배포 워크플로우를 최신 projectops 템플릿(모노레포 앱 경로 지원)으로 교체. 옛 템플릿은 `pubspec.yaml`, `lib/` 경로를 레포 루트 기준으로 찾아 산출물 업로드가 실패했다(옛 파일이 충돌로 갱신되지 않고 남은 것). 준비 안 된 배포 워크플로우는 자동 실행 중단.
- 2026-10-07 App Store 심사 제출(GitHub #347), `WAITING_FOR_REVIEW`.

## 근본 원인 (확정)
심사 정책 대응 항목 미구현. 워크플로우 업로드 실패는 옛 템플릿 파일이 남아 레포 루트 기준 경로를 찾은 것.

## 재발 방지
원본에 적혀 있지 않다. 남은 일로 App Store Connect 메타데이터(개인정보 처리방침 URL, 앱 개인정보 설문, 스크린샷, 심사용 테스트 계정)와 Android 릴리스 키스토어 SHA-1 등록(GitHub #339)이 적혀 있다.

## 교훈
(원본에 없음, 볼트 정리) iOS 심사 전에는 표시 이름·암호화 신고 키·앱 내 약관·Apple 탈퇴 토큰 회수·플레이스홀더 아이콘을 먼저 확인한다.
