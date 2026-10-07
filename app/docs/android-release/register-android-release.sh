#!/bin/bash
# Android 릴리스 서명을 마무리한다: 업로드 키 SHA-1 을 Firebase 에 등록하고 CI 시크릿을 만든다.
# 비밀 값은 이 맥에서만 처리한다. 키스토어는 ~/.passql-android-release/ 에 있다(분실 시 복구 불가: 백업할 것).
# 사용법: bash app/docs/android-release/register-android-release.sh
set -euo pipefail

D="$HOME/.passql-android-release"
KEY_PROPS="$D/key.properties"
FIREBASE_ADMIN_KEY=$(ls "$HOME"/Downloads/passql-firebase-adminsdk-*.json | head -1)
ANDROID_APP_ID=$(cat /tmp/new_android_appid.txt 2>/dev/null || echo "1:662424763183:android:75cef576d6ae3d9323bfda")
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CLI=$(find ~/.claude/plugins/cache -type f -path "*projectops/*/skills/pro-github/scripts/github_cli.py" 2>/dev/null | sort -V | tail -1)

prop() { grep "^$1=" "$KEY_PROPS" | cut -d= -f2-; }
set_secret() { SECRET_VALUE="$2" PYTHONIOENCODING=utf-8 python3 "$CLI" secrets set Twin-Fang passQL "$1" >/dev/null && echo "등록: $1"; }

# 1) 업로드 키 SHA-1 을 Firebase Android 앱에 등록 → 구글 로그인이 릴리스 빌드에서도 동작한다
SHA1=$(keytool -list -v -keystore "$D/upload-keystore.jks" -alias upload -storepass "$(prop storePassword)" 2>/dev/null | grep "SHA1:" | awk '{print $2}')
GOOGLE_APPLICATION_CREDENTIALS="$FIREBASE_ADMIN_KEY" npx --yes firebase-tools@latest apps:android:sha:create "$ANDROID_APP_ID" "$SHA1" --project passql || true
GOOGLE_APPLICATION_CREDENTIALS="$FIREBASE_ADMIN_KEY" npx --yes firebase-tools@latest apps:sdkconfig ANDROID "$ANDROID_APP_ID" --project passql --out "$ROOT/app/android/app/google-services.json"

# 2) CI 시크릿 (Play Store 워크플로우 형식)
set_secret RELEASE_KEYSTORE_BASE64 "$(base64 < "$D/upload-keystore.jks" | tr -d '\n')"
set_secret RELEASE_KEYSTORE_PASSWORD "$(prop storePassword)"
set_secret RELEASE_KEY_PASSWORD "$(prop keyPassword)"
set_secret RELEASE_KEY_ALIAS "$(prop keyAlias)"
set_secret GOOGLE_SERVICES_JSON "$(cat "$ROOT/app/android/app/google-services.json")"
set_secret ENV_FILE "$(cat "$ROOT/app/.env")"

echo "완료. Play Console 앱 생성과 서비스 계정(GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64)은 별도로 필요합니다."
