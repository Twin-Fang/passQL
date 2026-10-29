---
type: decision
id: DEC-0213
created: 2026-10-29
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0429-second-brain-vault-adoption]]", "[[ISS-0429-second-brain-vault-adoption-report]]"]
---

# DEC-0213: 볼트는 모노레포 knowledge/에 두고, pro-report 직후 지식화해 그 이슈의 같은 PR에 커밋한다

## 문제 정의 (Context)
결정 이유가 이슈·리포트 댓글에만 흩어져 있었다. 볼트를 어디에 두고 언제 채울지 정해야 했다 (GitHub #751).

## 결정 (Decision)
- 볼트 위치: 모노레포 루트 `knowledge/`.
- 시점: `pro-report`로 리포트 댓글을 올린 직후 `ingest-issue`로 지식화하고, 선택이 기록돼 있으면 결정 노트도 만든다.
- 커밋: 그 이슈 작업의 같은 PR. 번호가 겹치면 머지 직전 재번호, `log.md` 충돌은 양쪽 줄 유지.
- 규칙 원본: 프로젝트 `CLAUDE.md` 「지식화」 절.

## 검토한 대안 (Alternatives)
- 별도 레포: 레포 두 개 관리 부담, 코드 옆에 있어야 회수 이점이 있다는 이유로 쓰지 않음 (사용자 판단, 2026-10-27·10-29 대화. 원본 이슈에는 없음).
- 커밋 시점마다 지식화: 이슈 하나에 노트가 여러 개 생겨 리포트 시점으로 정함 (원본에 없음, 2026-10-29 대화).
- 머지 뒤 main에서 모아 적재: 사용자가 같은 PR을 택함 (2026-10-29 대화).

## 결과 (Consequences)
**긍정**
- 팀원이 `git pull`만 하면 같은 볼트를 쓴다.

**부정**
- 동시 PR끼리 노트 번호가 겹칠 수 있다 (CI 검사 없음).
- `CLAUDE.md` 규칙은 강제가 아니라 빠질 수 있다.

## 영향 범위 (Scope)
`CLAUDE.md`, `knowledge/`, 팀의 pro-github > pro-commit > pro-report 흐름.

## 출처 (References)
- GitHub #751 이슈 본문·리포트 댓글
- [[ISS-0429-second-brain-vault-adoption-report]]
