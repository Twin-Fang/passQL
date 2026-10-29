---
type: lesson
id: LSN-0001
created: 2026-10-29
reviewed: null
topics: [dev-workflow]
trigger: "코드나 문서를 고치기 시작할 때 (main 위에서 첫 수정 직전)"
status: active
source: "2026-10-29 세션 (GitHub #755 시작 시 사용자 확인)"
supersedes: null
superseded_by: null
related: ["[[DEC-0213-ingest-after-report-same-pr]]"]
---

# LSN-0001: 작업은 pro 스킬로 이슈와 브랜치를 먼저 만들고 진행한다

## 규칙
레포 파일(코드, 문서, 볼트)을 고치기 전에 `/pro-github`로 이슈를 만들고 그 이슈 브랜치(`YYYYMMDD_#번호_제목`)로 옮긴다. 이후 커밋은 `/pro-commit`, 리포트는 `/pro-report`, 닫기는 `finish-issue`로 한다. main에서 직접 고치지 않는다.

## Why
이 흐름은 개인 전역 지침과 에이전트 메모리에만 있었고, 볼트에는 규칙으로 남아 있지 않았다 (DEC-0213 본문에 배경으로 한 번 언급될 뿐). 다른 도구나 팀원이 같은 레포에서 작업할 때 볼트만 보고는 알 수 없어서, 사용자가 볼트에도 남기라고 정했다 (2026-10-29, #755 시작 때).

## How to apply
- 첫 수정 직전 현재 브랜치가 main(또는 다른 이슈 브랜치)이면 멈추고 `/pro-github`로 이슈부터 만든다.
- 이슈 제목은 레포에서 이미 쓰는 형식을 따른다 (예: `🎨[디자인][앱] 홈 화면 UI/UX 개편`).
- 리포트 뒤 지식화와 같은 PR 커밋은 [[DEC-0213-ingest-after-report-same-pr]]를 따른다.
- 앱 작업이면 push 뒤 이슈에 `@projectops app build <푸시된 브랜치>` 댓글을 단다. push는 사용자가 요청할 때만.
