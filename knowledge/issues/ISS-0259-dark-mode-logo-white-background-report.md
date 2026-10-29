---
type: completion-report
id: ISS-0259
created: 2026-10-15
topics: [design-system]
status: resolved
resolves: "[[ISS-0259-dark-mode-logo-white-background]]"
related: ["[[ISS-0265-brand-assets-single-source]]"]
source: "https://github.com/Twin-Fang/passQL/issues/453"
---

# ISS-0259 완료 리포트: 투명 로고·다크 로고 에셋, 공통 `PqLogo`, iOS 시작 화면 다크 이미지

GitHub #453 구현 보고서·후속 보고서 댓글(2026-10-15) 기준. 배포 v0.9.0(`555a81a`, #454·#455와 함께).

## 해결 방법
- `app/assets/logo.png`: 웹과 같은 투명 배경 로고로 교체(1336×364). `app/assets/logo_dark.png`(신규): 채도가 낮은 남색 픽셀("pass" 글자)만 흰색으로 바꾼 버전, 알파와 "QL" 그라데이션 유지.
- `PqLogo(height:)`(`app/lib/presentation/design/components/pq_logo.dart`, 신규): `Theme.of(context).brightness`로 에셋 선택. 로그인 `_Wordmark` 삭제 → `PqLogo(height: 44)`, 설정 `Image.asset('assets/logo.png')` → `PqLogo(height: 20)`.
- 후속(`eee18c3`): `LaunchImage.imageset` 라이트 168/336/504px 교체, 다크 `LaunchImageDark*.png` 3장 + `Contents.json` `appearances: luminosity=dark`. `LaunchScreen.storyboard` 이미지 크기 168×185 → 168×46. Android는 시작 화면에 로고 이미지가 없어 해당 없음.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본 주의사항: 다크 로고 변환 규칙 "불투명 픽셀 중 `max(R,G,B) < 120`이고 채도 차이 `< 70`인 픽셀만 흰색, 알파 유지". 로고는 `PqLogo`로만 쓴다. iOS는 시작 화면을 캐시해 업데이트 직후 옛 화면이 보일 수 있음(재설치·재시동으로 갱신).
- 로고 사본 여러 곳(앱 2장, LaunchImage 6장, 웹, 관리자 `static/images/logo.png` 흰 배경) — 하나의 원본에서 생성하는 작업은 아키텍처 정리에서 다룸 → GitHub #459.
- 검증: `flutter analyze lib` 이슈 없음, `flutter test` 223개 통과, `Assets.car`를 `assetutil`로 확인.

## 교훈
원본: "#453 수정 때 iOS 네이티브 쪽 사본을 조사하지 않았습니다." (원본에 없음, 볼트 정리) 에셋을 고칠 때는 플랫폼 네이티브 사본(LaunchImage 등)까지 grep한다.
