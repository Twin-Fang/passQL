---
type: issue
id: ISS-0294
created: 2026-10-15
topics: [store-release, community]
symptoms: [오픈소스 라이선스 고지 없음, LicensePage, 의견 보내기 기기 정보, 앱 버전 OS 첨부, device_info_plus]
root_cause: "설정에 오픈소스 라이선스 고지가 없었고, 의견 보내기에 앱 버전·OS 정보가 첨부되지 않았다(기능 공백)"
status: resolved
resolution: "[[ISS-0294-oss-license-menu-feedback-device-info-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/488"
---

# ISS-0294: 앱 설정에 오픈소스 라이선스 메뉴가 없고 의견 보내기에 기기 정보가 없음

GitHub #488 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 설정에 오픈소스 라이선스 고지가 없음.
- 의견 보내기에 앱 버전, OS 정보 자동 첨부 여부 확인 필요.
- 위치: `app/lib/presentation/pages/settings/settings_page.dart:143-176`.

## 재현 조건
해당 없음(기능 추가).

## 조사 기록
- 2026-10-15: 구현 중 `device_info_plus` 12.4.0이 iOS 26.1 SDK API를 써서 Xcode 26.0 빌드가 실패함을 확인 → 12.3.0 고정.

## 근본 원인
frontmatter `root_cause`와 같음.
