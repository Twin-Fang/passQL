# brand — 브랜드 자산 단일 원본

로고·아이콘·색의 원본은 이 폴더에만 둔다. 플랫폼 사본은 스크립트로 생성하고 손으로 고치지 않는다 (#459).

## 다시 만드는 명령

```bash
python3 brand/generate_brand_assets_for_all_platforms.py          # 사본 생성 (Pillow 필요)
python3 brand/generate_brand_assets_for_all_platforms.py --check  # 원본 <-> 사본 비교만 (CI 와 동일)
```

CI: `.github/workflows/PROJECT-COMMON-BRAND-ASSETS-CHECK.yaml` 이 `--check` 를 실행한다.

## 원본

| 파일 | 내용 |
|------|------|
| `logo_horizontal.png` | 가로 로고, 투명 배경 (1336x364) |
| `app_icon_1024.png` | 앱 아이콘, 불투명 (1024x1024) |
| `app_icon_adaptive_foreground.png` | Android 적응형 아이콘 전경, 투명 (1024x1024) |
| `brand-colors.json` | 브랜드 색 (accent 라이트·다크, 아이콘 배경, 시작 화면 배경, OG 배경) |

## 사본 (원본 > 사본)

| 원본 | 사본 | 만드는 방법 |
|------|------|-------------|
| `logo_horizontal.png` | `app/assets/logo.png`, `server/PQL-Web/src/main/resources/static/images/logo.png` | 그대로 복사 |
| `logo_horizontal.png` | `client/src/assets/logo/logo.png` | 높이 120px 축소 (웹 최대 표시 40px x 3배, 번들 크기 절감 #497) |
| `logo_horizontal.png` | `app/assets/logo_dark.png`, `server/.../static/images/logo_dark.png` | 다크 변환: 불투명 픽셀 중 max(R,G,B)<120 이고 채도 차이<70 > 흰색, 알파 유지 (#453) |
| `logo_horizontal.png` | `app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage{,@2x,@3x}.png`, `LaunchImageDark{,@2x,@3x}.png`, `Contents.json` | 폭 168/336/504px, 다크는 luminosity dark |
| `logo_horizontal.png` | `app/android/app/src/main/res/drawable-{mdpi..xxxhdpi}/launch_logo.png`, `drawable-night-{mdpi..xxxhdpi}/launch_logo.png` | 폭 168dp, Android 11 이하 시작 화면 (`launch_background.xml`) |
| `logo_horizontal.png` | `client/public/og-image.png` | 1200x630 흰 배경 가운데 로고 |
| `app_icon_1024.png` | `app/assets/app_icon_1024.png` | 그대로 복사 (flutter_launcher_icons 입력) |
| `app_icon_1024.png` | `client/public/favicon.png` (64x64), `server/PQL-Web/src/main/resources/static/favicon.ico` (16·32·48) | 축소 |
| `app_icon_1024.png` | `client/src/assets/logo/app_icon.png` (144x144) | 축소 (웹 앱 다운로드 배너 48px x 3배, #531) |
| `app_icon_adaptive_foreground.png` | `app/assets/app_icon_foreground.png` | 그대로 복사 (flutter_launcher_icons 입력) |

## 색 검사 (자동 수정 안 함)

`brand-colors.json` <-> 아래 값이 다르면 `--check` 실패:
Android `values/colors.xml`·`values-night/colors.xml` (`splash_background`, `ic_launcher_background`),
`app/pubspec.yaml` `adaptive_icon_background`, iOS `LaunchBackground.colorset`.
accent 는 기록용이다. 코드 토큰 원본은 각 스택 디자인 토큰 파일이다.

## 범위 밖

- 앱 아이콘(iOS AppIcon, Android mipmap): `app/` 에서 `dart run flutter_launcher_icons` 로 생성
- Android 12+ 시스템 스플래시: 앱 아이콘을 그대로 사용
