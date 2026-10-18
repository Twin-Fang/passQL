#!/usr/bin/env bash
# AI 해설 하네스 실행 (#521)
#   ./run.sh           오프라인: 현재 프롬프트 버전 기록본 검증 > server/PQL-Application/build/explanation-harness/report.md
#   ./run.sh live      실호출: GEMINI_API_KEY 필요 > recorded/v{버전}/ 기록본, reports/prompt-v{버전}.md 갱신
# 환경변수: EXPLANATION_HARNESS_MODEL(기본 gemini-3.5-flash-lite), EXPLANATION_HARNESS_WITH_RATIONALE=true(보기 근거 포함)
set -euo pipefail
SERVER_DIRECTORY="$(cd "$(dirname "$0")/../../server" && pwd)"

if [[ "${1:-}" == "live" ]]; then
  if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "[explanation harness] GEMINI_API_KEY 가 없음 (오프라인 모드는 인자 없이 실행)" >&2
    exit 1
  fi
  export EXPLANATION_HARNESS_LIVE=true
fi

# 환경변수가 바뀌어도 Gradle 이 테스트를 건너뛰지 않게 결과 삭제 후 실행
cd "$SERVER_DIRECTORY"
./gradlew :PQL-Application:cleanTest :PQL-Application:test --tests '*ExplanationHarnessTest*' -i \
  | grep -E "explanation harness|ExplanationHarnessTest|FAILED|PASSED|SKIPPED" || true
