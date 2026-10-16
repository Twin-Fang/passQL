#!/usr/bin/env bash
# 앱 자산 문서 암복호화: docs/sqld-research(원문, gitignore) <-> docs/sqld-research-encrypted(*.enc, 커밋)
# 사용: bash scripts/research-docs-crypt.sh encrypt|decrypt|install-hook
# 키: 루트 .env 의 RESEARCH_DOCS_ENCRYPTION_KEY (AES-256-CBC, PBKDF2 20만 회)
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
PLAIN_DIR="$REPO_ROOT/docs/sqld-research"
ENCRYPTED_DIR="$REPO_ROOT/docs/sqld-research-encrypted"
ENV_FILE="$REPO_ROOT/.env"
PBKDF2_ITERATIONS=200000

load_key() {
  if [ -z "${RESEARCH_DOCS_ENCRYPTION_KEY:-}" ] && [ -f "$ENV_FILE" ]; then
    RESEARCH_DOCS_ENCRYPTION_KEY="$(grep -E '^RESEARCH_DOCS_ENCRYPTION_KEY=' "$ENV_FILE" | head -1 | cut -d= -f2-)"
  fi
  [ -n "${RESEARCH_DOCS_ENCRYPTION_KEY:-}" ] || { echo "[research crypt] key missing: RESEARCH_DOCS_ENCRYPTION_KEY in .env" >&2; exit 1; }
  export RESEARCH_DOCS_ENCRYPTION_KEY
}

# .enc > stdout
decrypt_file() {
  openssl enc -d -aes-256-cbc -pbkdf2 -iter "$PBKDF2_ITERATIONS" -pass env:RESEARCH_DOCS_ENCRYPTION_KEY -in "$1" < /dev/null
}

# 원문 > .enc (내용 같으면 건너뜀: 매번 salt 가 달라 diff 노이즈 방지)
encrypt_all() {
  mkdir -p "$ENCRYPTED_DIR"
  local plain_file relative_path encrypted_file
  while IFS= read -r plain_file; do
    relative_path="${plain_file#"$PLAIN_DIR"/}"
    encrypted_file="$ENCRYPTED_DIR/$relative_path.enc"
    mkdir -p "$(dirname "$encrypted_file")"
    if [ -f "$encrypted_file" ] && decrypt_file "$encrypted_file" 2>/dev/null | cmp -s - "$plain_file"; then
      continue
    fi
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter "$PBKDF2_ITERATIONS" -pass env:RESEARCH_DOCS_ENCRYPTION_KEY \
      -in "$plain_file" -out "$encrypted_file" < /dev/null
    echo "[research crypt] encrypted : $relative_path"
  done < <(find "$PLAIN_DIR" -type f ! -name '.DS_Store')
}

# .enc > 원문 (로컬 원문이 더 새로우면 덮어쓰지 않음)
decrypt_all() {
  mkdir -p "$PLAIN_DIR"
  local encrypted_file relative_path plain_file
  while IFS= read -r encrypted_file; do
    relative_path="${encrypted_file#"$ENCRYPTED_DIR"/}"
    relative_path="${relative_path%.enc}"
    plain_file="$PLAIN_DIR/$relative_path"
    if [ -f "$plain_file" ] && [ "$plain_file" -nt "$encrypted_file" ]; then
      echo "[research crypt] skipped (local newer) : $relative_path"
      continue
    fi
    mkdir -p "$(dirname "$plain_file")"
    decrypt_file "$encrypted_file" > "$plain_file"
    echo "[research crypt] decrypted : $relative_path"
  done < <(find "$ENCRYPTED_DIR" -type f -name '*.enc')
}

# pre-commit: 암호화 후 .enc 만 스테이징 (기존 hook 있으면 덮어쓰지 않음)
install_hook() {
  local hook_file
  hook_file="$(git rev-parse --git-path hooks)/pre-commit"
  if [ -f "$hook_file" ] && ! grep -q 'research-docs-crypt' "$hook_file"; then
    echo "[research crypt] pre-commit exists, add manually: scripts/research-docs-crypt.sh encrypt && git add docs/sqld-research-encrypted" >&2
    exit 1
  fi
  cat > "$hook_file" <<'HOOK'
#!/usr/bin/env bash
# research-docs-crypt: 앱 자산 문서 자동 암호화 (원문 폴더·키 없으면 건너뜀)
REPO_ROOT="$(git rev-parse --show-toplevel)"
[ -d "$REPO_ROOT/docs/sqld-research" ] || exit 0
# 스크립트가 추적되는 작업트리만 (공유 hooks 라 다른 worktree 커밋에 섞임 방지)
git ls-files --error-unmatch scripts/research-docs-crypt.sh >/dev/null 2>&1 || exit 0
grep -q '^RESEARCH_DOCS_ENCRYPTION_KEY=' "$REPO_ROOT/.env" 2>/dev/null || exit 0
bash "$REPO_ROOT/scripts/research-docs-crypt.sh" encrypt && git add "$REPO_ROOT/docs/sqld-research-encrypted"
HOOK
  chmod +x "$hook_file"
  echo "[research crypt] hook installed : $hook_file"
}

case "${1:-}" in
  encrypt) load_key; encrypt_all ;;
  decrypt) load_key; decrypt_all ;;
  install-hook) install_hook ;;
  *) echo "usage: $0 encrypt|decrypt|install-hook" >&2; exit 2 ;;
esac
