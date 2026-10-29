---
type: issue
id: ISS-0145
created: 2026-04-18
topics: [dev-workflow]
symptoms: [gstack, CLAUDE.md, "슬래시 커맨드 부재", "/browse", "AI 협업 프로세스 제각각"]
root_cause: "Claude Code 기반 AI 워크플로우를 표준화할 공용 슬래시 커맨드 세트와 프로젝트 진입점(CLAUDE.md)이 없음"
status: resolved
resolution: "[[ISS-0145-install-gstack-add-claude-md-report]]"
related: ["[[DEC-0079-gstack-and-browse-only-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/270"
---

# ISS-0145: AI 협업 워크플로우용 공용 슬래시 커맨드와 CLAUDE.md가 없음

GitHub #270 (원본: 이슈 본문과 리포트 댓글).

## 증상
- Claude Code에서 기획·리뷰·QA·배포·보안 감사를 체계적으로 쓸 공용 슬래시 커맨드 세트가 없다.
- 팀원마다 AI 협업 프로세스(기획→설계→리뷰→QA→릴리즈)가 달라 일관된 품질 게이트를 강제하기 어렵다.
- `/review`, `/qa`, `/ship`, `/cso` 등을 호출할 환경(전역 설치 + 프로젝트 진입점)이 없다.

## 재현 조건
해당 없음 (도구 도입).

## 조사 기록
- 2026-04-18: 제안 — gstack `v0.18.3.0`을 `~/.claude/skills/gstack`에 전역 설치, `setup`으로 슬래시 커맨드 등록, 루트에 `CLAUDE.md` 생성. 미완료 체크 항목: `CLAUDE.md` 커밋·푸시 여부 결정, 팀 모드(`./setup --team` + `gstack-team-init`) 검토.

## 근본 원인
해당 없음 (도구 미도입).
