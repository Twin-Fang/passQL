---
type: decision
id: DEC-0177
created: 2026-10-24
reviewed: null
topics: ["dev-workflow"]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0391-expand-abbreviated-local-names]]", "[[ISS-0391-expand-abbreviated-local-names-report]]"]
---

# DEC-0177: 약어 풀어쓰기는 컴파일러·타입 검사로 확인 가능한 지역 이름만 — 계약 이름·프레임워크 시그니처·관용 표현·관리자 정적 JS·테스트는 제외

GitHub #642 (원본: 이슈 본문 「배경」「하지 않는 것」과 완료 리포트 「하지 않은 것과 이유」).

## 문제 정의 (Context)
코드 구조 점검(2026-10-24)에서 이름 규칙(약어 금지, boolean 접두사) 위반 후보가 나왔다. 어디까지 바꿀지 범위를 정해야 했다.

## 결정 (Decision)
- 바꾸는 것: 컴파일러·타입 검사로 확인 가능한 앱·서버·웹 지역 이름. 동작 변경 없음.
- 바꾸지 않는 것: 서버 JSON·API 파라미터와 묶인 계약 이름(`alreadyCompleted`, `reported`, `latestTrend` 등), 프레임워크 시그니처·오버라이드(`shouldRebuild`, `build(overlapsContent)`), 관용 표현(`copyWith`의 `clearX`), React `loading`/`submitting` 상태 이름, 관리자 정적 JS(`question-import-export.js`), 테스트 코드.
- 새 이름이 이미 쓰이는 파일은 건너뛴다(`ResultMatchChoiceValidator.val`, `MarkdownText.el`).

## 검토한 대안 (Alternatives)
- 관리자 정적 JS까지 바꾸기: 버림. 원본 이유 — "검사 도구가 없어 이름만 바꿔도 깨졌는지 알 수 없음".
- 계약 이름·프레임워크 오버라이드·관용 표현·React 상태 이름·테스트 코드 바꾸기: 버림. 원본은 제외 목록만 적었고 항목별 이유는 관리자 정적 JS 외에 따로 적지 않았다.

## 결과 (Consequences)
**긍정**
- 앱 테스트 397개·웹 테스트 125개 통과, 서버 컴파일 성공으로 동작 변경 없음을 확인했다.

**부정**
- 관리자 정적 JS와 계약 이름 등 제외 대상에는 약어 이름이 남는다(원본에 없음, 볼트 정리).

## 영향 범위 (Scope)
앱(Dart)·서버(Java)·웹(TypeScript) 지역 이름, PR #643의 19개 파일.

## 출처 (References)
- GitHub #642 이슈 본문, 완료 리포트 댓글(PR #643)
- [[ISS-0391-expand-abbreviated-local-names]]
