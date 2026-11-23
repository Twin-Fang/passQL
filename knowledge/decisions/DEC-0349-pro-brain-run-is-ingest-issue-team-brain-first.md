---
type: decision
id: DEC-0349
created: 2026-11-23
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0546-pro-brain-knowledge-switch-claude-md-merge]]", "[[DEC-0213-ingest-after-report-same-pr]]", "[[DEC-0214-no-local-design-docs-in-public-vault]]"]
---

# DEC-0349: 이슈 지식화는 /pro-brain으로 실행하고 그 실행이 곧 ingest-issue이며, "왜" 질문은 팀 브레인 MCP를 먼저 찾는다

GitHub #1169.

## 문제 정의 (Context)
pro-brain을 passQL에 켜면서 지식화 시점 지시가 두 곳(「지식화」 절의 ingest-issue, pro-brain 블록의 /pro-brain)에 생길 상황이었다. 같은 이슈에 노트가 두 벌 생기거나 어느 쪽을 따를지 헷갈릴 수 있었다.

## 결정 (Decision)
- 시점: `/pro-report` 후 이슈를 닫기 전에 `/pro-brain`을 실행한다. 이 실행이 `SECOND-BRAIN.md`의 `ingest-issue`이며, 노트를 따로 하나 더 만들지 않는다.
- pro-brain은 메타데이터 키(`capture_mode`, `issue_url`, `commit_base` 등)를 frontmatter에 덧붙이기만 하고, 노트 형식·번호·폴더는 `SECOND-BRAIN.md`가 정한다.
- "왜 이렇게 됐나, 무엇을 정했나" 질문은 팀 브레인 MCP(`gbrain-passql`)를 먼저 찾고, 연결돼 있지 않으면 `knowledge/`를 읽는다.
- 역할 분담: 시점·검색 순서는 CLAUDE.md pro-brain 블록(pro-brain 관리), 레포 고유 운영 규칙은 블록 밖 「지식화」 절.
- 설정 원본: `version.yml` > `metadata.template.options.knowledge`.

## 검토한 대안 (Alternatives)
- 블록을 파일 끝에 그대로 두고 「지식화」 절도 그대로 두기: 같은 시점 지시가 두 곳에 남아 채택하지 않음(구현 중 판단, 사용자 논의 기록 없음).
- 블록 대신 「지식화」 절만 손으로 고치기: pro-brain이 블록 상태를 `absent`로 보고 다시 붙이므로 채택하지 않음(구현 중 판단).

## 결과 (Consequences)
**긍정**
- 지식화 절차가 하나로 읽힌다. 팀원 PC에 팀 브레인 정보가 없어도 같은 노트를 쓴다.
- 노트에 이슈·PR·커밋 범위·설정 키 같은 메타데이터가 붙어 필터 검색이 된다.

**부정**
- 블록 안 문장은 pro-brain 갱신 때 덮어써지므로 손으로 고치면 사라진다.

## 영향 범위 (Scope)
`CLAUDE.md` 「지식화」 절과 pro-brain 블록, `version.yml` knowledge 스위치, 모든 이슈의 pro-report > pro-brain > finish-issue 흐름.

## 출처 (References)
- GitHub #1169 이슈 본문, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1169#issuecomment-7090109045
- PR #1170

## W4 검사
- DEC-0213(볼트 위치·pro-report 직후·같은 PR): 시점과 PR 규칙은 그대로, 실행 이름만 /pro-brain으로 묶음. 충돌 없음, 대체 아님.
- DEC-0214(퍼블릭 볼트에 서버 경로·호스트 금지): 노트와 블록에 MCP 이름만 쓰고 주소는 쓰지 않음. 충돌 없음.
