---
type: decision
id: DEC-0064
created: 2026-04-12
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0098-applayout-nav-daisyui-classes]]", "[[ISS-0098-applayout-nav-daisyui-classes-report]]"]
---

# DEC-0064: 웹은 `data-theme="passql"`로 라이트 테마를 고정한다 (OS 다크모드 무시)

## 문제 정의 (Context)
GitHub #179 작업 중 브라우저 OS 다크모드 설정에 따라 daisyUI가 자동으로 다크 테마를 적용하는 문제가 발견됐다.

## 결정 (Decision)
`index.html`의 `<html>` 태그에 `data-theme="passql"`을 넣어 테마를 강제 고정한다. 리포트가 밝힌 이유: "passQL은 라이트 모드 전용 디자인이므로 테마 강제 고정 필요."

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- OS 다크모드 설정과 무관하게 passQL 라이트 테마 유지(리포트 검증 항목).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
웹 `client/index.html`, daisyUI 테마 전체.

## 출처 (References)
- GitHub #179 작업 리포트 댓글 「daisyUI passql 테마 강제 적용」 (2026-04-12)
- [[ISS-0098-applayout-nav-daisyui-classes]]
