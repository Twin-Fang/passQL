#!/usr/bin/env bash
# app/.env 의 iOS AdMob 앱 ID > ios/Flutter/AdMob.xcconfig (커밋 제외 생성 파일)
# Info.plist 의 GADApplicationIdentifier 는 빌드 타임 값이라 flutter_dotenv 로 주입 불가 > xcconfig 로 전달
# 값이 없으면 파일을 비워 둠 > Debug/Release.xcconfig 의 Google 테스트 앱 ID 사용 (비면 SDK 가 앱 시작 시 종료시킴)
# 호출: ios/Podfile 이 pod install 마다 자동 실행. 수동: app 폴더에서 `bash tool/gen_ios_admob_config.sh`
set -euo pipefail

APP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$APP_ROOT/.env"
OUTPUT_FILE="$APP_ROOT/ios/Flutter/AdMob.xcconfig"
ENV_KEY="PASSQL_ADMOB_IOS_APP_ID"

# 첫 번째 KEY= 줄의 값 (주석 줄 제외, CR·앞뒤 공백 제거)
read_env_value() {
  [ -f "$ENV_FILE" ] || return 0
  grep -E "^[[:space:]]*$1=" "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '\r' | xargs || true
}

ADMOB_IOS_APP_ID="$(read_env_value "$ENV_KEY")"

mkdir -p "$(dirname "$OUTPUT_FILE")"
{
  echo "// 자동 생성 파일 - 직접 고치지 않음. tool/gen_ios_admob_config.sh 가 app/.env 로 생성"
  if [ -n "$ADMOB_IOS_APP_ID" ]; then
    echo "$ENV_KEY=$ADMOB_IOS_APP_ID"
  fi
} > "$OUTPUT_FILE"

if [ -n "$ADMOB_IOS_APP_ID" ]; then
  echo "[admob ios config] written : $ENV_KEY from .env"
else
  echo "[admob ios config] $ENV_KEY empty : Google test app id will be used"
fi
