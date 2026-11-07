# 스토어 자산 (한국어 전용)

| 경로 | 내용 |
|---|---|
| `promo/source/` | 원본 캡처 (`tool/store_shots/capture_store_set.sh`, iPhone 16 Pro 시뮬레이터, 다크·라이트 장면별) |
| `promo/ios-6.9/` `promo/ios-6.5/` `promo/ios-6.3/` `promo/android-phone/` | 홍보 이미지 8장 (1320x2868 · 1284x2778 · 1206x2622 · 2160x3840). 1, 2장은 스토어 간격을 고려해 이어지는 한 쌍. App Store 필수 칸은 6.3", 다른 iPhone 크기는 이 이미지를 축소해 씀 |
| `promo/feature-graphic.png` | Play 그래픽 이미지 1024x500 |
| `play-listing-icon-512.png` | Play 등록정보 앱 아이콘 512x512. `brand/generate_brand_assets_for_all_platforms.py` 가 앱 아이콘 원본에서 생성, Play Console 에 직접 올림 (App Store 는 앱 빌드 아이콘을 씀) |
| `descriptions/` | Play 이름·짧은·전체 설명, App Store 이름·부제·프로모션·키워드·설명 (콘솔 입력값의 원본, 콘솔에 직접 반영) |

생성: 문구는 `tool/store_art/scenes.json` 만 고치고 `python3 -I app/tool/store_art/render.py` (레포 루트에서).

- 원본 캡처 다시 찍기: `bash app/tool/store_shots/capture_store_set.sh` (16 Pro 의 passQL 이 캡처용 앱으로 바뀜, `flutter run` 하면 돌아옴)
- 색·글꼴은 앱 디자인 토큰만 쓴다 (`lib/presentation/design/tokens/`). 그라데이션 글자·글로우·빛 번짐 배경 금지
- 그래픽 이미지에 "Get it on Google Play" 배지·가격 문구를 넣지 않는다 (메타데이터 정책)
- 문구와 홍보 이미지에 문제 수(몇 문제 이상 등)를 쓰지 않는다 (사용자에게 문제량을 노출하지 않는 방침, #636)
- 이미지에는 PRO 표시를 넣지 않는다. 결제 스위치를 켜면 프로 전용 기능(SQL 실행·실전 모드·출제 경향 등)이 생기므로 **스위치를 켤 때 설명 문구에 무료·프로 구분을 반드시 추가한다** (#576, #596, App Store 심사 기준 2.3.2)
