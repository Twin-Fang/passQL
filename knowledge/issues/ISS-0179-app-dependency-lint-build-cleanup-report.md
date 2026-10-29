---
type: completion-report
id: ISS-0179
created: 2026-10-07
topics: [ci-deploy, dev-workflow]
status: resolved
resolves: "[[ISS-0179-app-dependency-lint-build-cleanup]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/334"
---

# ISS-0179 완료 리포트: 버전 제약 안 업그레이드 완료, 메이저 업그레이드는 후속

GitHub #334 1단계 완료 댓글(2026-10-02)과 2026-10-07 댓글 기준.

## 해결 방법
- 현재 제약 안에서 올릴 수 있는 패키지 모두 업그레이드(dio 5.9 -> 5.11, go_router 17.2 -> 17.5, flutter_svg 2.3, animations 2.2, flutter_dotenv 6.0.1, uuid 4.6 등 전이 의존성 포함).
- dio 5.10+ `transformTimeout`을 타임아웃으로 분류하도록 에러 변환기 수정, 테스트 추가.
- iOS `Podfile.lock`, 플랫폼별 플러그인 등록 파일 동기화.
- 검증(2026-10-02): `flutter analyze` 0건, 테스트 114개, 안드로이드 디버그 APK, iOS 시뮬레이터 빌드(`kr.suhsaechan.passql`) 후 로그인 화면 확인. 2026-10-07: 테스트 147개, Android AAB·iOS IPA 릴리스 빌드 성공.

## 근본 원인 (확정)
원본에 하나의 원인으로 적혀 있지 않다.

## 재발 방지
- 메이저 업그레이드는 별도 이슈 권장: riverpod 계열(2.6 → 3.x/4.x, 가장 큰 작업), freezed·json_serializable·build_runner, retrofit(4.7/9.7 → 4.10/10.x), flutter_secure_storage(9.2 → 11.2, 토큰 저장소 영향), flutter_local_notifications(19.5 → 22.3), fl_chart 등.
- `.env`는 빌드 시 에셋으로 번들되고 CI가 `ENV_FILE` 시크릿으로 생성. 로컬에 없으면 `asset_does_not_exist` 경고. 주입 방식(`--dart-define` 등)은 CI 정리(GitHub #336)와 함께 결정하기로 남김.

## 교훈
(원본에 없음, 볼트 정리) 의존성 업그레이드 뒤 enum에 새 값이 추가되면 exhaustive 분기(에러 변환기 등)가 컴파일 에러로 드러난다 — 업그레이드 후 분기 처리부터 본다.
