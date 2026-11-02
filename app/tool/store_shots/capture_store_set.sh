#!/bin/bash
# 스토어 홍보 이미지 원본 캡처 전체 재촬영: bash app/tool/store_shots/capture_store_set.sh
# 주의: iPhone 16 Pro 의 passQL 이 캡처용 앱으로 바뀐다 (flutter run 하면 돌아옴)
set -euo pipefail

# 사용 중인 시뮬레이터만 쓴다. 다른 기기를 켜면 용량을 차지한다
DEVICE=7C60B597-45B8-4F82-97EE-67F3C2FE7B9B
BUNDLE=com.coldredrice.passql
APP_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$APP_ROOT/docs/store/promo/source"
ROUTE_FILE=/tmp/passql_shot_route.txt
CONCEPT=/concept-study/44444444-0000-4000-8000-000000000014

cd "$APP_ROOT"
# 결제 꺼짐: 앱의 PRO 칩·이용권 줄이 찍히지 않게 한다
flutter build ios --simulator -t tool/store_shots/main_shots.dart --dart-define=SHOT_PLAN=off

original_appearance="$(xcrun simctl ui "$DEVICE" appearance)"
restore() {
  xcrun simctl ui "$DEVICE" appearance "$original_appearance"
  xcrun simctl status_bar "$DEVICE" clear
  xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
  rm -f "$ROUTE_FILE"
}
trap restore EXIT

xcrun simctl install "$DEVICE" build/ios/iphonesimulator/Runner.app
xcrun simctl status_bar "$DEVICE" override --time 9:41 --batteryState discharging --batteryLevel 100 --cellularBars 4 --wifiBars 3

shot() {
  local name="$1" route="$2" appearance="$3"
  xcrun simctl ui "$DEVICE" appearance "$appearance"
  xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
  echo "$route" > "$ROUTE_FILE"
  xcrun simctl launch "$DEVICE" "$BUNDLE" > /dev/null
  # 앱 시작·연출이 끝날 시간 (짧으면 로딩 화면이 찍힘)
  sleep 10
  xcrun simctl io "$DEVICE" screenshot --type=png "$OUT/$name.png" 2>/dev/null
  echo "shot $name"
}

shot s1_execute execute-ok dark
shot s3_real_mode real-mode light
shot s4_ai ai-sheet dark
shot s5_trend /exam-trend light
shot s6_stats /stats dark
shot s7_concept "$CONCEPT" dark
shot s7_concept_light "$CONCEPT" light
shot s8_leader /leaderboard light
