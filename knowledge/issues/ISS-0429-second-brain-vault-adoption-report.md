---
type: completion-report
id: ISS-0429
created: 2026-10-29
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0429-second-brain-vault-adoption]]"
related: ["[[DEC-0213-ingest-after-report-same-pr]]", "[[DEC-0214-no-local-design-docs-in-public-vault]]"]
source: "https://github.com/Twin-Fang/passQL/issues/751"
---

# ISS-0429 완료 리포트: 모노레포 knowledge/ 볼트와 전체 이슈 백필

GitHub #751 리포트 댓글 기준 (2026-10-29).

## 해결 방법
- 템플릿 `EM-H20/second-brain-template`(커밋 `14498e9a` 고정)을 모노레포 루트에 설치. `.gitattributes`에 `knowledge/log.md merge=union`.
- 이슈 428개(#751 제외), 완료 리포트 347개, 결정 212개, 주제 클러스터 18개 적재. 노트 `source:`는 GitHub 이슈 URL, `_sources/` 사본 없음.
- 결정 충돌 정리: 대체 체인 14개, 폐기 6개, 상호 링크 18쌍(사용자 확인, 판단이 필요한 4건은 main 코드로 확인).
- `CLAUDE.md` 「지식화」 절 → [[DEC-0213-ingest-after-report-same-pr]]. 그래프 색 상태별 분리, `workspace.json` 무시.
- 퍼블릭 레포라 NAS 경로·운영 도메인·내부 포트를 push 전 브랜치 커밋 전체에서 가림.

## 근본 원인 (확정)
결정 이력을 회수할 저장소 부재.

## 재발 방지
- 원본에 없는 이유·대안은 "논의 기록 없음", 볼트 정리 문장은 "(원본에 없음, 볼트 정리)" 표기. 시험 적재에서 지어낸 문장 8곳이 나와 생긴 규칙.
- 노트 번호는 폴더 최댓값+1이라 동시 PR끼리 겹칠 수 있다 → 머지 직전 재번호와 `vault.mjs check`.
- `merge=union`을 GitHub PR 충돌 판정이 따르는지는 미확인 → `log.md` 충돌은 양쪽 줄 유지.

## 교훈
(원본에 없음, 볼트 정리) 이슈를 지식화하는 `ingest-issue`는 결정 노트를 만들지 않는다. 선택이 기록된 리포트는 결정 노트를 따로 만들어야 "왜"가 회수된다.
