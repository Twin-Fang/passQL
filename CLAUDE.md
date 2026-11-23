# passQL — 모노레포 마스터 인덱스 (AI 진입점)

passQL은 **4개 스택을 한 레포에서 관리하는 모노레포**다. 작업 대상 스택의
`CLAUDE.md`를 먼저 읽고 그 규칙을 따른다. 이 문서는 전체 네비게이션 + 공통 규칙.

## 스택 네비게이션

| 스택 | 폴더 | 진입점 | 역할 |
|------|------|--------|------|
| Frontend | `client/` | [client/CLAUDE.md](client/CLAUDE.md) | React + Vite + TS 웹 |
| Backend | `server/` | [server/CLAUDE.md](server/CLAUDE.md) | Spring 멀티모듈 (API·관리자) |
| AI Server | `ai/` | [ai/CLAUDE.md](ai/CLAUDE.md) | Python FastAPI (LLM·벡터검색) |
| App | `app/` | [app/CLAUDE.md](app/CLAUDE.md) | Flutter 모바일 앱 |

**통신 구조**: client/app ──(/api)──> server(Spring) ──(x-api-key)──> ai(FastAPI).
프론트(client/app)는 **server하고만 통신**한다. ai 서버 직접 호출 금지.

## 문서 위치 (예측 가능한 경로)

| 종류 | 위치 |
|------|------|
| 앱 PRD, 스토어 출시·Firebase 가이드 | `app/docs/` |
| AI 작업 산출물 (이슈 초안·계획·스펙·캡처) | `docs/projectops/`, `docs/superpowers/` — 로컬 전용(.gitignore), 결과는 GitHub 이슈에 남긴다 |

스택 전용 문서는 각 스택 폴더 내부(`{stack}/docs/`, `{stack}/.claude/rules/`)에 둔다.

## API 계약 단일 원본 (`api-contract/openapi.json`)

- 서버 `/api/**` 스펙의 원본. 서버 API(경로·DTO·ErrorCode)를 바꾸면 갱신 > 웹 타입 재생성까지 한 커밋에.
  - 갱신: `cd server && ./gradlew :PQL-Web:test --tests '*OpenApiContractTest*' -PupdateApiContract`
  - 웹: `cd client && npm run gen:api` (`src/types/generated/openapi.ts`, 손으로 고치지 않음)
- 강제: 서버 `OpenApiContractTest`(스펙 <-> 파일), 웹 CI(gen:api 후 diff 없음), 앱 `error_code_contract_test.dart`(앱 매핑 코드 ⊂ 서버 ErrorCode).

## 버전·배포 (CI 자동 관리 — 수동 수정 금지)

- `version.yml` = 단일 버전 기준. `CHANGELOG.json/md`는 워크플로우가 자동 갱신.
- `.github/workflows/` = CI/CD. main push → deploy PR → automerge → 시놀로지 배포.

### 앱 브랜치 빌드 트리거

- 앱 작업은 이슈 등록 > 커밋 > 푸시 후 해당 이슈에 아래 댓글을 단다 (`/pro-github` 사용)
- 형식: `@projectops app build <작업브랜치>`
- 예: `@projectops app build 20261026_#500_기능개선_홈_화면`

## 공통 금지 규칙 (모든 스택)

- **`git push`는 사용자 명시 요청 시에만** — 임의 push 금지.
- **민감 정보 커밋 절대 금지** — `.env*`, PAT/토큰, API 키, firebase-service-account,
  keystore 등. push 전 시크릿 스캔 필수. (`.gitignore` 신뢰하되 staged 재확인)
- **커밋 메시지 Co-Authored-By 태그 금지.**
- **파일 삭제 시 사용자 허락.**
- **답변은 항상 한국어로** (코드/커맨드 제외).
- **모르면 모른다고 말하기** — 추측 금지.
- **코드 주석 필수** — WHY 중심의 간결한 한국어 주석.

## 지식화 (세컨드 브레인 `knowledge/`)

코드에 남지 않는 "왜 이렇게 됐나"를 볼트에 쌓는다. 언제 남기고 어디서 먼저 찾는지는 아래 pro-brain 블록, 노트 형식·절차의 원본은 `SECOND-BRAIN.md`.

- `/pro-brain` 실행 = `SECOND-BRAIN.md`의 `ingest-issue` 실행. 이슈 노트(`ISS`)를 만들거나 열린 이슈 노트를 완료 리포트로 닫고, pro-brain 메타데이터 키(`capture_mode`, `issue_url`, `commit_base` 등)는 frontmatter에 덧붙이기만 한다(노트를 따로 하나 더 만들지 않음).
- 리포트에 선택(무엇을 고르고 무엇을 버렸나)이 기록돼 있으면 결정 노트(`DEC`)도 만들고, 이전 결정을 바꿨으면 대체 체인(`supersedes`/`superseded_by`)으로 잇는다.
- 만들어진 `knowledge/` 노트는 그 이슈 작업의 **같은 PR에** 커밋한다.
- 번호(`ISS-`/`DEC-`)는 폴더 최댓값+1이라 동시에 열린 PR끼리 겹칠 수 있다. 머지 직전 최신 main을 받아 겹치면 내 쪽 번호를 올리고 `node second-brain/tools/vault.mjs check`를 돌린다.
- `knowledge/log.md` 충돌은 양쪽 줄을 모두 남겨 푼다(덧붙이기 전용 파일).
- 원본에 없는 이유·대안은 지어내지 않고 "논의 기록 없음"으로 쓴다. 노트 `source:`는 GitHub 이슈 URL.

<!-- pro-brain:begin (managed by /pro-brain; settings live in version.yml) -->
## 프로젝트 지식 (pro-brain)

나중에도 유효한 프로젝트 지식(결정, 이유, 주의점)은 `knowledge/` 폴더에 노트로 남긴다. 팀 브레인은 `main` 브랜치에서 이 폴더를 가져간다. 노트 형식과 절차는 `SECOND-BRAIN.md`를 따른다.

- **언제 남기나**: `/pro-report`로 이슈 보고서를 올린 뒤, 이슈를 닫기 전에 `/pro-brain`을 실행한다 (이슈마다 노트 1건).
- **왜 이렇게 됐는지, 무엇을 정했는지 답하기 전에**: 팀 브레인 MCP(`gbrain-passql`)에서 먼저 찾는다. 연결돼 있지 않으면 `knowledge/` 폴더를 읽는다 (주제, 파일, 이슈 번호로 검색).
- 사소한 변경은 이유 한 줄로 건너뛴다. 비밀값, 개인정보, 대화 내용은 노트에 넣지 않는다.
- 설정: `version.yml` > `metadata.template.options.knowledge`.
<!-- pro-brain:end -->

---

## gstack
Use /browse from gstack for all web browsing. Never use mcp__claude-in-chrome__* tools.
Available skills: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review,
/design-consultation, /design-shotgun, /design-html, /review, /ship, /land-and-deploy,
/canary, /benchmark, /browse, /open-gstack-browser, /qa, /qa-only, /design-review,
/setup-browser-cookies, /setup-deploy, /retro, /investigate, /document-release, /codex,
/cso, /autoplan, /pair-agent, /careful, /freeze, /guard, /unfreeze, /gstack-upgrade, /learn.

@SECOND-BRAIN.md
