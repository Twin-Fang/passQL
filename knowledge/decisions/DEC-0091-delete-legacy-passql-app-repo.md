---
type: decision
id: DEC-0091
created: 2026-10-07
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0180-passql-app-monorepo-merge-docs]]", "[[ISS-0180-passql-app-monorepo-merge-docs-report]]"]
---

# DEC-0091: 앱 코드 기준은 모노레포 `app/`, 구 `passQL-app` 레포는 백업 후 삭제한다

## 문제 정의 (Context)
앱 코드가 `passQL-app`과 모노레포 `app/` 두 곳에 있었고, 구 레포의 보관 처리 방침(읽기 전용 보관 또는 삭제)을 정해야 했다 (GitHub #335).

## 결정 (Decision)
- 모노레포 `app/`가 기준이다(2026-10-02, `passQL-app`의 `lib/`와 동일 확인).
- 구 `passQL-app` 레포는 passQL-Lab 조직과 함께 삭제한다(2026-10-07 "구 레포 처리 결정", Twin-Fang 이전 GitHub #351). 삭제 전 git 기록 전체를 로컬 미러 `~/Downloads/passql-backup/passQL-app.git`로 백업.

## 검토한 대안 (Alternatives)
- 읽기 전용 보관: 2026-10-02 댓글에 후보로 적혔고 삭제를 택했다. 보관을 버린 이유는 논의 기록 없음(삭제는 조직 이전 GitHub #351과 함께 진행).

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음. 구 레포 기록은 로컬 미러 백업에만 남는다(원본 사실).

## 영향 범위 (Scope)
앱 개발 위치(`app/`), `app/docs/`, GitHub 조직(passQL-Lab → Twin-Fang).

## 출처 (References)
- GitHub #335 진행 댓글(2026-10-02), "구 레포 처리 결정" 댓글(2026-10-07)
