---
type: decision
id: DEC-0067
created: 2026-04-12
reviewed: null
topics: [question-bank, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0108-admin-guide-table-naming-rule]]", "[[ISS-0108-admin-guide-table-naming-rule-report]]"]
---

# DEC-0067: 문제 스키마 테이블 이름은 시험 회차·번호 대신 짧고 의미 있는 이름으로

## 문제 정의 (Context)
관리자가 `SQLD_14`, `SQLD46_01_EMP`처럼 시험 회차·문제 번호를 테이블 이름에 써서 학습자 화면(SchemaViewer)에 시험 내부 코드가 노출됐다. 각 문제는 독립 Sandbox(격리된 DB)에서 실행되어 문제 간 테이블 이름 충돌이 없다 (GitHub #193).

## 결정 (Decision)
문제 등록 시 테이블 이름은 데이터 성격에 맞는 짧은 이름(`EMP`, `DEPT`, `T1` 등, 상황별 권장 이름 표 제공)을 쓴다. 의미 없는 더미 데이터(AND/OR 우선순위 테스트 등)는 `T1`, `T2`, `TAB_A`. 단건·대량 가이드, 관리자 가이드 모달, AI 변환 프롬프트에 같은 규칙을 둔다.

## 검토한 대안 (Alternatives)
- 시험 회차·문제 번호를 넣은 이름(`SQLD_14` 등): 학습자 화면 가독성이 떨어지고 Sandbox 격리로 충돌 회피도 필요 없어 쓰지 않기로 함(이슈 본문).

## 결과 (Consequences)
**긍정**
- 학습자 화면에 내부 코드가 노출되지 않고, 관리자가 충돌 걱정 없이 짧은 이름을 쓴다.

**부정**
- 기존 문제는 자동 수정되지 않는다. AI가 규칙을 반드시 따른다는 보장이 없어 관리자 검토가 필요(리포트 주의사항).

## 영향 범위 (Scope)
`static/docs/question-single-guide.md`, `question-bulk-guide.md`, `templates/admin/question-register.html`, `templates/admin/questions.html`(가이드 모달·AI 변환 프롬프트), 문제 콘텐츠 작성 관행.

## 출처 (References)
- GitHub #193 이슈 본문, 리포트 댓글 (2026-04-12)
- [[ISS-0108-admin-guide-table-naming-rule]]
