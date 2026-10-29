---
type: decision
id: DEC-0214
created: 2026-10-29
reviewed: null
topics: [dev-workflow, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0429-second-brain-vault-adoption]]", "[[ISS-0429-second-brain-vault-adoption-report]]"]
---

# DEC-0214: 퍼블릭 레포 볼트에는 로컬 전용 설계 문서를 넣지 않고, 서버 경로·호스트·내부 포트를 쓰지 않는다

## 문제 정의 (Context)
레포가 퍼블릭이라 볼트에 넣는 내용은 모두 공개된다. 시놀로지 서버의 설계·계획·조사 문서와 운영 정보를 넣을지 정해야 했다 (GitHub #751).

## 결정 (Decision)
- `docs/superpowers/` 같은 로컬 전용(비공개) 설계·계획 문서와 서버 `docs/` 문서는 볼트에 넣지 않는다.
- 노트에 NAS 경로, 운영 도메인, 운영 내부 포트, 서버 계정, 이메일, 회원 정보, 키 값을 쓰지 않는다. 이미 커밋했으면 push 전 기록에서도 지운다.

## 검토한 대안 (Alternatives)
- 위험이 낮은 설계 문서만 요약해 넣기: 공개 범위가 바뀐다는 이유로 넣지 않기로 함 (2026-10-29 대화, 원본 이슈에는 없음).

## 결과 (Consequences)
**긍정**
- 팀이 비공개로 둔 문서의 공개 범위가 바뀌지 않는다.

**부정**
- 설계 문서에만 있는 배경은 볼트에서 회수되지 않는다. 이슈·리포트에 요약된 범위까지만 남는다.

## 영향 범위 (Scope)
`knowledge/` 전체 노트 작성.

## 출처 (References)
- GitHub #751 리포트 댓글 「주요 구현 내용 4·5」
- [[ISS-0429-second-brain-vault-adoption-report]]
