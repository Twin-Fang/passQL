---
type: completion-report
id: ISS-0180
created: 2026-10-07
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0180-passql-app-monorepo-merge-docs]]"
related: ["[[DEC-0091-delete-legacy-passql-app-repo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/335"
---

# ISS-0180 완료 리포트: 문서 `app/docs/` 이관, 구 `passQL-app` 레포 삭제 결정

GitHub #335 진행 댓글(2026-10-02)과 "구 레포 처리 결정" 댓글(2026-10-07) 기준.

## 해결 방법
- `PRD.md`, `be-api-docs.json`을 `app/docs/`로 이관(커밋 `092d24b`). 모노레포 `app/`를 앱 코드 기준으로 확정.
- 구 `passQL-app` 레포는 passQL-Lab 조직과 함께 삭제하기로 결정(Twin-Fang 이전 GitHub #351). 삭제 전 git 기록 전체를 로컬 미러(`~/Downloads/passql-backup/passQL-app.git`)로 백업.
- "서버 OpenAPI를 앱/웹 공통 계약으로 쓰는 방안 검토"의 결론은 #335 원본에 적혀 있지 않다.

## 근본 원인 (확정)
해당 없음.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
원본에 적혀 있지 않다.
