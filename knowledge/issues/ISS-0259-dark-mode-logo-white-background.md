---
type: issue
id: ISS-0259
created: 2026-10-15
topics: [design-system]
symptoms: [다크 모드 로고 흰 박스, "logo.png 흰 배경", 로그인 로고 텍스트 대체, "TODO: 전용 다크 로고 에셋 필요", LaunchImage 흰 배경, iOS 시작 화면 다크]
root_cause: "앱에 알파 채널 없는 흰 배경 로고 하나뿐이었고, iOS LaunchImage는 별도 사본이라 #453 1차 수정에서 빠졌다"
status: resolved
resolution: "[[ISS-0259-dark-mode-logo-white-background-report]]"
related: ["[[ISS-0265-brand-assets-single-source]]", "[[ISS-0256-app-apple-style-redesign-dark-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/453"
---

# ISS-0259: 다크 모드에서 passQL 로고가 흰 배경으로 보이고 로그인 로고가 텍스트로 대체됨

GitHub #453 (원본: 이슈 본문, 구현 보고서, 배포 댓글, 후속 보고서).

## 증상
- 설정 화면 하단: `app/assets/logo.png`가 불투명 흰 배경 PNG라 다크 배경 위에 흰 박스.
- 로그인 화면: 다크 모드에서 로고 대신 Pretendard 텍스트("pass" + "QL"), 코드에 `TODO: 전용 다크 로고 에셋 필요`.
- 후속(사용자가 실기기에서 발견): iOS 시작 화면(LaunchScreen)도 다크 모드에서 로고가 흰 박스째로 보임.

## 재현 조건
기기를 다크 모드로 → 로그인 화면(텍스트 로고), 설정 맨 아래(흰 박스), 앱 시작 직후(iOS 시작 화면 흰 박스).

## 조사 기록
- 2026-10-15: 웹(`client/src/assets/logo/logo.png`)에 같은 로고의 투명 배경 버전이 있음.
- 2026-10-15 후속: `app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage*.png`는 알파 없는 흰 배경(#341에서 교체). `LaunchBackground`는 라이트 흰색·다크 검정으로 이미 나뉘어 배경과 이미지가 어긋남. 로고 원본이 Flutter `assets/`, iOS `LaunchImage`, 웹, 관리자 페이지에 따로 복사돼 있었고 1차 수정 때 iOS 네이티브 사본을 조사하지 않았다.

## 근본 원인
frontmatter `root_cause`와 같음.
