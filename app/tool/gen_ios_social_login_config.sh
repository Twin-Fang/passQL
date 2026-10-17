#!/usr/bin/env bash
# app/.env 의 소셜 로그인 값 4개 > ios/Flutter/SocialLogin.xcconfig (커밋 제외 생성 파일, #509)
# 대상: KAKAO_NATIVE_APP_KEY(URL 스킴 kakao{키}), NAVER_CLIENT_ID·NAVER_CLIENT_SECRET·NAVER_CLIENT_NAME(Info.plist Nid*)
# Info.plist 값은 빌드 타임 값이라 flutter_dotenv 로 주입 불가 > xcconfig 로 전달 (secret 을 git 에 남기지 않음)
# 값이 없으면 줄을 생략 > Debug/Release.xcconfig 의 빈 기본값 사용 (앱은 해당 버튼에서 준비 중 안내)
# 호출: ios/Podfile 이 pod install 마다 자동 실행. 수동: app 폴더에서 `bash tool/gen_ios_social_login_config.sh`
set -euo pipefail

APP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$APP_ROOT/.env"
OUTPUT_FILE="$APP_ROOT/ios/Flutter/SocialLogin.xcconfig"
ENV_KEYS=(KAKAO_NATIVE_APP_KEY NAVER_CLIENT_ID NAVER_CLIENT_SECRET NAVER_CLIENT_NAME)

# 첫 번째 KEY= 줄의 값 (주석 줄 제외, CR·앞뒤 공백 제거)
read_env_value() {
  [ -f "$ENV_FILE" ] || return 0
  grep -E "^[[:space:]]*$1=" "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '\r' | xargs || true
}

# xcconfig 안전 문자만 허용 (// 는 주석, $ 는 변수 치환으로 해석돼 값이 깨짐)
is_xcconfig_safe_value() {
  [[ "$1" =~ ^[A-Za-z0-9._-]+$ ]]
}

mkdir -p "$(dirname "$OUTPUT_FILE")"
{
  echo "// 자동 생성 파일 - 직접 고치지 않음. tool/gen_ios_social_login_config.sh 가 app/.env 로 생성"
  for key in "${ENV_KEYS[@]}"; do
    value="$(read_env_value "$key")"
    if [ -z "$value" ]; then
      echo "[social login ios config] $key empty : default (empty) used" >&2
    elif ! is_xcconfig_safe_value "$value"; then
      echo "[social login ios config] $key rejected : unsupported characters for xcconfig" >&2
    else
      echo "$key=$value"
      echo "[social login ios config] written : $key from .env" >&2
    fi
  done
} > "$OUTPUT_FILE"
