---
type: decision
id: DEC-0079
created: 2026-04-18
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0145-install-gstack-add-claude-md]]", "[[ISS-0145-install-gstack-add-claude-md-report]]"]
---

# DEC-0079: AI 워크플로우는 gstack 슬래시 커맨드를 쓰고, 웹 브라우징은 `/browse`만 쓴다

## 문제 정의 (Context)
팀원마다 AI 협업 프로세스가 달라 일관된 품질 게이트를 강제하기 어려웠다(GitHub #270).

## 결정 (Decision)
- gstack(`v0.18.3.0`)을 각자 `~/.claude/skills/gstack`에 전역 설치해 슬래시 커맨드를 쓴다.
- passQL 루트 `CLAUDE.md`에 `## gstack` 섹션을 두고, 웹 브라우징은 `/browse`만 쓰며 `mcp__claude-in-chrome__*` 도구는 쓰지 않는다.
- 이슈 본문의 사용 시나리오: 기획 `/office-hours` → `/plan-ceo-review` → `/plan-eng-review`, 구현 후 `/review` → `/qa <staging-url>` → `/ship`, 보안 `/cso`, 디버깅 `/investigate`.

## 검토한 대안 (Alternatives)
논의 기록 없음. (`mcp__claude-in-chrome__*` 금지의 이유도 원본에 적혀 있지 않다.) 팀 모드(`./setup --team` + `gstack-team-init`)는 적용하지 않고 추후 결정으로 남겼다.

## 결과 (Consequences)
**긍정**
- 이슈 본문 예상 동작: 레포 클론 후 팀원이 같은 AI 워크플로우 규약을 공유.

**부정**
- gstack 미설치 팀원은 별도 설치해야 커맨드가 동작한다(리포트 주의사항).

## 영향 범위 (Scope)
루트 `CLAUDE.md`, 개발자 로컬 `~/.claude/skills/gstack`. 앱 코드 영향 없음.

## 출처 (References)
- GitHub #270 이슈 본문, 리포트 댓글(2026-04-18)
