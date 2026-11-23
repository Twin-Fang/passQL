---
type: completion-report
id: ISS-0546
created: 2026-11-23
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0546-pro-brain-knowledge-switch-claude-md-merge]]"
related: ["[[DEC-0349-pro-brain-run-is-ingest-issue-team-brain-first]]", "[[DEC-0213-ingest-after-report-same-pr]]"]
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

# ISS-0546 완료 리포트: pro-brain 스위치를 켜고 「지식화」 절과 pro-brain 블록을 한 덩어리로 정리 (#1169)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1169#issuecomment-7090109045 · PR #1170 (main 머지, 배포 전)

## 해결 방법
- `version.yml` > `metadata.template.options.knowledge`: `enabled: true`, `path: knowledge/`, `capture: issue-end`, `claude_md: CLAUDE.md`, `brain_mcp: gbrain-passql`, `rules: SECOND-BRAIN.md`, `note_dir: issues/`, `template: _templates/completion-report.md`, `check: node second-brain/tools/vault.mjs check`.
- `CLAUDE.md`: pro-brain 블록(`pro-brain:begin/end` 마커)을 파일 끝에서 「지식화」 절 바로 아래로 옮기고, 절 첫 항목을 "`/pro-brain` 실행 = `ingest-issue` 실행"으로 바꿈 — [[DEC-0349-pro-brain-run-is-ingest-issue-team-brain-first]].
- 번호 충돌·`log.md` 충돌·지어내지 않기·같은 PR 규칙은 「지식화」 절에 그대로 둠.

## 근본 원인 (확정)
조사 기록과 같음.

## 재발 방지
- `brain_cli.py setup` 재실행 시 `version_yml_diff`·`block_diff`가 비어 있고 `rule_block_state: current`. 블록은 마커 사이를 제자리 교체하므로 위치를 옮겨도 갱신이 같은 자리에서 일어난다.
- `vault.mjs check` errors 0, `brain_cli.py gaps` 노트 빠진 작업 0건.

## 남은 일
- 이 노트는 PR #1170 머지 뒤 후속 지식화 PR로 올렸다(같은 PR 원칙 DEC-0213의 예외, #1166 지식화 PR과 같은 방식).
- `deploy` 반영은 다음 정규 릴리스.

## 교훈
- pro-brain 블록 안 문장은 pro-brain이 다시 쓴다. 레포 고유 규칙은 블록 밖 「지식화」 절에 둔다.
- `version.yml`이 바뀐 main push는 VERSION-CONTROL이 릴리스 머지로 보고 버전 증가를 건너뛴다.
