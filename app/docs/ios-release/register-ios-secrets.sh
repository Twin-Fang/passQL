#!/bin/bash
# iOS TestFlight 배포(GitHub Actions)에 필요한 시크릿을 이 맥에서 읽어 레포에 등록한다.
#
# 비밀 값은 이 스크립트가 사용자 맥에서만 처리한다(대화나 로그에 출력하지 않는다).
# 실행 전 준비:
#   1) 키체인에 "Apple Distribution" 인증서가 있어야 한다 (Xcode 에 로그인된 팀 CUK22HY6YC)
#   2) App Store Connect API 키 파일: ~/Downloads/AuthKey_9S3Y25UVZN.p8
#   3) 이 레포의 app/.env, app/ios/Runner/GoogleService-Info.plist 가 있어야 한다
#   4) pro-github 스킬에 PAT 가 등록되어 있어야 한다
# 사용법: bash app/docs/ios-release/register-ios-secrets.sh
set -euo pipefail

REPO_OWNER="Twin-Fang"; REPO_NAME="passQL"
BUNDLE_ID="com.coldredrice.passql"
ASC_KEY_ID="9S3Y25UVZN"
ASC_ISSUER_ID="5e4f25aa-151d-4c7b-8a0a-bdca9408b91b"   # App Store Connect > 사용자 및 액세스 > 통합 > Issuer ID
KEY_FILE="$HOME/Downloads/AuthKey_${ASC_KEY_ID}.p8"
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
APP="$ROOT/app"

CLI=$(find ~/.claude/plugins/cache -type f -path "*projectops/*/skills/pro-github/scripts/github_cli.py" 2>/dev/null | sort -V | tail -1)
[ -n "$CLI" ] || { echo "pro-github 스킬(github_cli.py)을 찾지 못했습니다."; exit 1; }

set_secret() {  # $1=이름 $2=값 (값은 환경변수로만 전달한다)
  SECRET_VALUE="$2" PYTHONIOENCODING=utf-8 python3 "$CLI" secrets set "$REPO_OWNER" "$REPO_NAME" "$1" >/dev/null \
    && echo "등록: $1"
}
b64() { base64 < "$1" | tr -d '\n'; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# 1) 배포 인증서(.p12) — 키체인에서 내보내 임의 비밀번호로 보호한다
P12_PW=$(python3 -c "import secrets,string;print(''.join(secrets.choice(string.ascii_letters+string.digits) for _ in range(32)))")
security export -k ~/Library/Keychains/login.keychain-db -t identities -f pkcs12 -P "$P12_PW" -o "$TMP/cert.p12" >/dev/null
set_secret APPLE_CERTIFICATE_BASE64 "$(b64 "$TMP/cert.p12")"
set_secret APPLE_CERTIFICATE_PASSWORD "$P12_PW"

# 2) 앱스토어 프로비저닝 프로파일(Xcode 가 자동 생성한 것)
PROFILE_NAME="iOS Team Store Provisioning Profile: $BUNDLE_ID"
PROFILE_FILE=""
for f in ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*; do
  name=$(security cms -D -i "$f" 2>/dev/null | python3 -c "import plistlib,sys;print(plistlib.loads(sys.stdin.buffer.read()).get('Name',''))" 2>/dev/null || true)
  [ "$name" = "$PROFILE_NAME" ] && PROFILE_FILE="$f" && break
done
[ -n "$PROFILE_FILE" ] || { echo "프로파일을 찾지 못했습니다: $PROFILE_NAME (Xcode 로 한 번 아카이브하세요)"; exit 1; }
set_secret APPLE_PROVISIONING_PROFILE_BASE64 "$(b64 "$PROFILE_FILE")"
set_secret IOS_PROVISIONING_PROFILE_NAME "$PROFILE_NAME"

# 3) App Store Connect API 키
[ -f "$KEY_FILE" ] || { echo "API 키 파일이 없습니다: $KEY_FILE"; exit 1; }
set_secret APP_STORE_CONNECT_API_KEY_BASE64 "$(b64 "$KEY_FILE")"
set_secret APP_STORE_CONNECT_API_KEY_ID "$ASC_KEY_ID"
set_secret APP_STORE_CONNECT_ISSUER_ID "$ASC_ISSUER_ID"

# 4) 앱 식별자와 환경 설정
set_secret IOS_BUNDLE_ID "$BUNDLE_ID"
set_secret ENV_FILE "$(cat "$APP/.env")"
set_secret GOOGLE_SERVICE_INFO_PLIST_BASE64 "$(b64 "$APP/ios/Runner/GoogleService-Info.plist")"

echo "완료. Actions 탭에서 PROJECT-FLUTTER-IOS-TESTFLIGHT 를 실행하세요(workflow_dispatch)."
