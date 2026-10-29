---
type: completion-report
id: ISS-0294
created: 2026-10-15
topics: [store-release, community]
status: resolved
resolves: "[[ISS-0294-oss-license-menu-feedback-device-info]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/488"
---

# ISS-0294 완료 리포트: 설정 > 정보 "오픈소스 라이선스", 의견에 앱·OS·기기 정보 첨부

GitHub #488 구현 보고서 댓글 기준 (2차 통합본).

## 해결 방법
- 설정 > 정보에 "오픈소스 라이선스"(`LicensePage`, 글꼴 OFL 라이선스 등록).
- 의견 전송 시 앱 버전, OS 버전, 기기 모델(`device_info_plus`)을 본문 하단에 첨부. 합쳐서 서버 상한 500자를 넘으면 본문만 전송.
- `device_info_plus`는 `12.3.0`으로 고정(`12.4.0`은 iOS 26.1 SDK API를 써서 Xcode 26.0 빌드 실패).
- 검증: `flutter analyze` 경고 0, `flutter test` 292개 통과.

## 근본 원인 (확정)
기능 공백(버그 아님).

## 재발 방지
`device_info_plus` 버전 고정 이유는 위와 같다. 해제 조건은 원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) iOS 빌드가 갑자기 실패하면 플러그인 새 버전이 설치된 Xcode보다 새 SDK API를 쓰는지 확인한다.
