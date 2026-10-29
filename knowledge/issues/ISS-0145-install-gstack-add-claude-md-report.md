---
type: completion-report
id: ISS-0145
created: 2026-04-18
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0145-install-gstack-add-claude-md]]"
related: ["[[DEC-0079-gstack-and-browse-only-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/270"
---

# ISS-0145 완료 리포트: gstack setup 재실행, 루트 `CLAUDE.md`에 `## gstack` 섹션

GitHub #270 `## 개요` 리포트 댓글(2026-04-18) 기준.

## 해결 방법
- 이미 있던 `~/.claude/skills/gstack`(`VERSION` `0.18.3.0`)에서 `./setup` 재실행, `gstack ready (claude)` 및 `linked skills: ...` 출력으로 확인. `/browse` 바이너리 `~/.claude/skills/gstack/browse/dist/browse` 확인.
- passQL 루트에 `CLAUDE.md` 신규 — `## gstack` 섹션 하나: 웹 브라우징은 `/browse`만, `mcp__claude-in-chrome__*` 사용 금지, 슬래시 커맨드 32종 나열.
- `.issue/20260418_#119_gstack_설치_및_프로젝트_CLAUDE_md_추가.md` 신규.
- 서버·프론트·Flyway·CI 변경 없음.

## 근본 원인 (확정)
해당 없음 (도구 도입).

## 재발 방지
리포트 주의사항: 리포트 시점에 `CLAUDE.md`와 `.issue/` 파일은 미커밋(Untracked). 팀 모드 미적용 — 개인 환경에만 연결, 팀 전원 적용은 별도 이슈. `CLAUDE.md`는 각자 gstack이 설치돼 있다는 전제를 따른다.

## 교훈
논의 기록 없음.
