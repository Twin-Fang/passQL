---
type: issue
id: ISS-0180
created: 2026-10-02
topics: [dev-workflow]
symptoms: [passQL-app, "모노레포 통합", "be-api-docs.json 구버전", "PRD.md 이관", "구 레포 보관", "OpenAPI 공통 계약"]
root_cause: "앱 코드가 `passQL-app`과 모노레포 `app/` 두 곳에 있고 문서 이관이 커밋 전"
status: resolved
resolution: "[[ISS-0180-passql-app-monorepo-merge-docs-report]]"
related: ["[[DEC-0091-delete-legacy-passql-app-repo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/335"
---

# ISS-0180: passQL-app 통합 마무리 및 API 문서 정리

GitHub #335 (원본: 이슈 본문과 댓글 2개). 문서 이슈.

## 증상
(현재 문제점) 앱 코드가 `passQL-app`과 모노레포 `app/` 두 곳에 같은 내용으로 있다. 문서(`PRD.md`, `be-api-docs.json`)만 `app/docs/`로 복사됐고 커밋 전. `be-api-docs.json`은 2026-04 기준 구버전.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02: 모노레포 `app/`가 기준이며 `passQL-app`의 `lib/`와 동일 확인. 이후 앱 작업(GitHub #327 ~ #334)은 모노레포 `app/`에서 진행. 문서 이관 커밋 `092d24b`. `be-api-docs.json`은 v0.0.3 구버전으로 서버 코드가 기준, `app/.claude/rules/api-guide.md`도 서버 코드 기준으로 갱신됨.
- 남은 것(당시): 구 레포 보관 처리, 서버 OpenAPI를 앱/웹 공통 계약으로 쓰는 방안 검토.
- 2026-10-07: 구 레포 삭제 결정.

## 근본 원인
해당 없음 (통합 정리 작업).
