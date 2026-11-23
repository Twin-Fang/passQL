---
type: issue
id: ISS-0546
created: 2026-11-23
topics: [dev-workflow]
symptoms: ["pro-brain switch_off", "지식화 꺼짐", "knowledge 스위치 없음", "version.yml knowledge", "pro-brain 규칙 블록 중복", "ingest-issue와 pro-brain 두 번", "팀 브레인 MCP 먼저 찾기", "gbrain-passql", "노트 빠진 머지 작업"]
root_cause: "볼트와 SECOND-BRAIN.md 규칙은 있었지만 version.yml에 pro-brain 스위치가 없어 pro-brain이 레포를 꺼짐으로 봤고, 지식화 시점 지시가 CLAUDE.md 「지식화」 절에만 있어 pro-brain 블록을 그대로 붙이면 같은 지시가 두 곳에 생겼다"
status: resolved
resolution: "[[ISS-0546-pro-brain-knowledge-switch-claude-md-merge-report]]"
related: ["[[DEC-0213-ingest-after-report-same-pr]]", "[[DEC-0214-no-local-design-docs-in-public-vault]]", "[[DEC-0349-pro-brain-run-is-ingest-issue-team-brain-first]]", "[[ISS-0429-second-brain-vault-adoption]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1169"
capture_mode: "issue-end"
captured_at: "2026-11-23T11:40:02+09:00"
captured_by: "pro-brain"
project: "passql"
app_version: "1.143.4"
build_number: 612
issue: 1169
issue_url: "https://github.com/Twin-Fang/passQL/issues/1169"
pr: 1170
pr_url: "https://github.com/Twin-Fang/passQL/pull/1170"
branch: "20261123_#1169_기능추가_지식화_pro_brain_적용_지식_스위치와_CLAUDE_md_지식화_규칙_통합"
commit_base: "2e3d0e9ea6ba47171b91f3f7b7d213ab33419796"
commit_head: "0e0ca970b8b59b06ffe3ee2b2c58ec500f487c46"
commit_count: 1
merge_commit: "e02358e5"
changed_modules: ["(root)"]
main_files: ["CLAUDE.md", "version.yml"]
lines_added: 24
lines_deleted: 2
config_keys: ["version.yml:metadata.template.options.knowledge.enabled", "version.yml:metadata.template.options.knowledge.path", "version.yml:metadata.template.options.knowledge.capture", "version.yml:metadata.template.options.knowledge.claude_md", "version.yml:metadata.template.options.knowledge.brain_mcp", "version.yml:metadata.template.options.knowledge.rules", "version.yml:metadata.template.options.knowledge.note_dir", "version.yml:metadata.template.options.knowledge.template", "version.yml:metadata.template.options.knowledge.check"]
---

# ISS-0546: pro-brain 지식 스위치 적용과 CLAUDE.md 지식화 규칙 통합 (#1169)

GitHub: https://github.com/Twin-Fang/passQL/issues/1169

## 증상
- pro-brain `status`가 passQL을 `switch_off`(지식화 꺼짐)로 판단했다. `version.yml`에 `metadata.template.options.knowledge` 블록이 없었다.
- 팀 브레인은 main의 `knowledge/`를 가져가지만, "왜 이렇게 됐나" 질문에 팀 브레인 MCP를 먼저 찾으라는 규칙이 CLAUDE.md에 없었다.
- pro-brain `setup`이 규칙 블록을 CLAUDE.md 끝에 덧붙여, 「지식화」 절의 "pro-report 직후 ingest-issue"와 블록의 "pro-report 후 /pro-brain"이 따로 놓였다.

## 재현 조건
pro-brain `brain_cli.py status` / `setup`을 passQL 루트에서 실행.

## 조사 기록
- 2026-11-23: `setup` 계획이 recommended capture `issue-end`(최근 300커밋 중 150개가 이슈 링크, 이슈 브랜치 다수), 규칙 블록 대상 `CLAUDE.md`(추적 파일)를 제안했다.
- 2026-11-23: `setup`은 `enabled`·`path`·`capture`·`claude_md`·`brain_mcp`·`rules`만 쓰고 `note_dir`·`template`·`check`는 쓰지 않는다.
- 2026-11-23: `AGENTS.md`는 second-brain 템플릿 관리 파일이라 블록 대상에서 뺐다.

## 근본 원인
스위치가 레포에 없었고, 지식화 시점 규칙의 원본이 「지식화」 절 하나뿐이라 pro-brain 블록과 역할이 나뉘어 있지 않았다.
