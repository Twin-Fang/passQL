#!/usr/bin/env bash
# passQL 소개 사이트 시놀로지 배포: 빌드 > 확인 파일 복사 > tar·ssh 업로드(html·설정) > 공개 주소 확인
# 사용: gh-pages 작업 트리 루트에서  bash _src/synology/deploy_synology.sh
# 접속 정보: pro-launch 저장 자격(기본 synology-chan4760, NAS_CRED 로 변경) — 레포에 주소·포트·계정을 두지 않음
# 비밀번호: SSHPASS 가 없으면 같은 자격에서 읽어 sshpass -e 로 전달 (출력 안 함)
set -euo pipefail

NAS_CRED="${NAS_CRED:-synology-chan4760}"
LAUNCH_CLI="${PROJECTOPS_HOME:-$HOME/.projectops}/bin/launch_cli.py"
# 자격 필드 1개 읽기 (password 만 --reveal)
read_cred_field() {
  local reveal_flag=""
  [ "$1" = "password" ] && reveal_flag="--reveal"
  PYTHONIOENCODING=utf-8 python3 "$LAUNCH_CLI" cred show --name "$NAS_CRED" $reveal_flag \
    | python3 -I -c "import sys,json; print(json.load(sys.stdin)['credential'].get('$1',''))"
}
NAS_HOST="$(read_cred_field host)"
NAS_PORT="$(read_cred_field port)"
NAS_USER="$(read_cred_field user)"
[ -n "$NAS_HOST" ] && [ -n "$NAS_USER" ] || { echo "[site deploy] pro-launch cred '$NAS_CRED' not found" >&2; exit 1; }
if [ -z "${SSHPASS:-}" ] && command -v sshpass >/dev/null; then
  SSHPASS="$(read_cred_field password)"
  export SSHPASS
fi
# 컨테이너 passql-site 가 바인드하는 폴더 (html/, nginx.conf, security-headers.inc, docker-compose.yml)
REMOTE_DIR="/volume1/projects/passql/site"
SITE_URL="https://passql.suhsaechan.kr"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD_DIR="$(mktemp -d)/site"
trap 'rm -rf "$(dirname "$BUILD_DIR")"' EXIT

# 1. 새 주소 기준 전체 사이트 생성 (privacy·terms 는 운영 API 본문을 받아오므로 네트워크 필요)
cd "$REPO_ROOT"
python3 -I _src/build_site.py --out "$BUILD_DIR" --custom-domain

# 2. 검색엔진 소유 확인 파일 (Google·네이버) — 지우면 소유 확인이 풀림
find _src/site_verification -maxdepth 1 -type f -name "*.html" -exec cp {} "$BUILD_DIR"/ \;

# 3. 업로드: tar 묶음을 ssh 로 보내 NAS 에서 풀고, html 은 NAS 로컬 rsync --delete 로 원본과 똑같이 맞춤
#    (시놀로지는 rsync 앱 권한 없는 계정의 ssh 경유 rsync 를 인증 단계에서 거부 > tar 사용)
#    (빌드 임시 폴더가 700 권한 > 컨테이너 nginx(uid 101) 가 읽도록 a+rX)
#    (html 폴더 자체를 바꿔치기하면 컨테이너 바인드 마운트가 옛 폴더를 계속 봄 > 내용만 동기화)
STAGE_DIR="$(dirname "$BUILD_DIR")/upload"
mkdir -p "$STAGE_DIR"
cp -R "$BUILD_DIR" "$STAGE_DIR/html"
cp _src/synology/docker-compose.yml _src/synology/nginx.conf _src/synology/security-headers.inc "$STAGE_DIR"/
ARCHIVE_PATH="$(dirname "$BUILD_DIR")/site.tar.gz"
COPYFILE_DISABLE=1 tar --no-xattrs --no-mac-metadata -czf "$ARCHIVE_PATH" -C "$STAGE_DIR" .

REMOTE_APPLY_COMMAND="set -e; cd $REMOTE_DIR; rm -rf .incoming; mkdir .incoming; tar -xzf - -C .incoming; \
mkdir -p html; rsync -rlt --delete .incoming/html/ html/; \
cp .incoming/docker-compose.yml .incoming/nginx.conf .incoming/security-headers.inc .; rm -rf .incoming; \
chmod -R a+rX html docker-compose.yml nginx.conf security-headers.inc; echo uploaded"
SSH_OPTIONS=(-p "$NAS_PORT" -o StrictHostKeyChecking=accept-new)
# NAS 가 맞는 비밀번호도 간헐적으로 거부함(Permission denied) > 최대 5회 재시도
upload_attempt=1
until { if [ -n "${SSHPASS:-}" ]; then sshpass -e ssh "${SSH_OPTIONS[@]}" "$NAS_USER@$NAS_HOST" "$REMOTE_APPLY_COMMAND"; \
        else ssh "${SSH_OPTIONS[@]}" "$NAS_USER@$NAS_HOST" "$REMOTE_APPLY_COMMAND"; fi; } < "$ARCHIVE_PATH"; do
  [ "$upload_attempt" -ge 5 ] && { echo "[site deploy] upload failed" >&2; exit 1; }
  echo "[site deploy] upload failed (attempt $upload_attempt), retrying" >&2
  upload_attempt=$((upload_attempt + 1))
  sleep 3
done

# 4. 공개 주소 확인 (html 은 바인드 마운트라 재시작 불필요)
for page_path in / /sqld/schedule/ /robots.txt /sitemap.xml; do
  # 확인 실패(000)도 배포 실패로 보지 않음 > 결과만 출력
  status_code=$(curl -s -o /dev/null -w '%{http_code}' "$SITE_URL$page_path" || true)
  echo "[site deploy] $status_code $SITE_URL$page_path"
done
echo "[site deploy] nginx.conf 를 바꿨다면 NAS 에서: sudo /usr/local/bin/docker exec passql-site nginx -s reload"
