# 스토어 자산 (한국어 전용)

| 경로 | 내용 |
|---|---|
| `promo/source/` | 원본 캡처 (`tool/store_shots`, iOS 시뮬레이터 다크 모드) |
| `promo/ios-6.9/` `promo/ios-6.5/` `promo/android-phone/` | 홍보 이미지 7장 (1320x2868 · 1284x2778 · 1080x1920) |
| `promo/feature-graphic.png` | Play 그래픽 이미지 1024x500 |
| `descriptions/` | Play 짧은·전체 설명, App Store 부제·프로모션·키워드·설명 |

생성: 문구는 `tool/store_art/scenes.json` 만 고치고 `python3 -I app/tool/store_art/render.py` (레포 루트에서).

- 원본 캡처 다시 찍기: `tool/store_shots/main_shots.dart` 빌드 > `/tmp/passql_shot_route.txt` 에 경로·연출(`execute-ok`, `ai-sheet` 등) > launch
- 그래픽 이미지에 "Get it on Google Play" 배지·가격 문구를 넣지 않는다 (메타데이터 정책)
- 문구 속 숫자(300문제 이상)는 운영 활성 문제 수 기준 — 문제 수가 바뀌면 함께 확인
- 결제 스위치를 켜면 프로 전용 기능(출제 경향·통계 등)이 생기므로 설명 문구에 무료·프로 구분을 추가한다 (#576)
