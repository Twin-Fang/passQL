---
type: decision
id: DEC-0292
created: 2026-11-12
reviewed: null
topics: [practice, question-bank, design-system, concept-learning]
status: active
supersedes: DEC-0278
superseded_by: null
related: ["[[DEC-0278-stem-blocks-single-table-shape]]", "[[ISS-0502-stem-table-same-columns-overwritten]]", "[[ISS-0504-question-structure-audit-harness]]", "[[ISS-0472-stem-readability-blocks-single-table]]"]
---

# DEC-0292: 지문 표 자리에 스키마 표를 끼울 때는 이름이 같을 때만(이름 없는 지문 표만 컬럼 비교), 코드 제목은 짧은 이름표 주석만 — 그 밖의 지문 블록 규칙은 DEC-0278 그대로

## 문제 정의 (Context)
[[DEC-0278-stem-blocks-single-table-shape]]의 "같은 컬럼 구성의 지문 표가 있으면 그 자리에 스키마 표를 한 번만" 규칙 때문에, 이름이 다른데 컬럼이 같은 표(`[EMP]`·`PROJ` 둘 다 `ID, DEPT_NO`)가 있으면 EMP가 PROJ로 덮여 사라졌다. "첫 줄 `-- 라벨`은 상자 위 캡션" 규칙은 제약 설명 주석까지 제목으로 떼어 냈다 (GitHub #1015, [[ISS-0502-stem-table-same-columns-overwritten]]). 운영 활성 499건 중 17건이 앱에서 표가 사라졌다([[ISS-0504-question-structure-audit-harness]]).

## 결정 (Decision)
- **스키마 표 대체:** 이름이 같은 지문 표 자리에만 끼운다. 지문 표에 이름이 없을 때만 컬럼 서명으로 찾는다. 한 번 대체한 지문 표 자리는 다시 쓰지 않는다. 예시 행이 없는 스키마 표는 지문 표의 행을 유지한다. 대응하는 지문 표가 없으면 지문 카드에 추가로 그린다.
- **코드 제목:** 짧은 이름표 주석(`-- SQL 1` 같은)만 상자 위 캡션으로 뗀다. 그 밖의 `--` 주석은 코드 안 회색 주석으로 남긴다.
- **같은 기준 네 곳:** 앱 `stem_blocks.dart`, 웹 `stemSchemaTablePlacement.ts`·`stemBlocks.ts`, 서버 `QuestionFormatRule`(형식 검사·자동 정리, `[이름]` 표는 같은 이름 스키마 표와만 비교), 하네스 lint(이름 다른 같은 컬럼 표 warning).
- **DEC-0278에서 그대로인 것:** 지문 블록 6종(단락, 보조 설명, 질문, 목록, 표, 코드)과 판정 규칙, 앱·웹 두 구현과 양쪽 최소 테스트, 표 한 가지 모양(컬럼 이름 + PK, FK, 행 전부, 자료형·샘플 표시 없음, 별도 "테이블 N개" 카드 없음), SQL 상자(얇은 테두리, 코드 속 한글은 본문 글꼴, 웹 긴 줄 가로 스크롤), 코드 글꼴 D2Coding 부분 글꼴, 개념 글 소제목 `: ` 구분자.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 「예상 동작」이 "표는 이름이 같을 때만 스키마 표로 바뀐다", "짧은 이름표 주석만 코드 제목"을 제시.)

## 결과 (Consequences)
**긍정**
- 이름 다른 같은 컬럼 표가 사라지지 않는다. 운영 활성 499건 앱·웹 재검증 표 소실 0건.

**부정 / 조건**
- 이름표 없는 지문 표(`T1` 한 줄 머리말)는 여전히 컬럼 서명 매칭이라, 이름 없는 같은 컬럼 표가 여럿이면 순서에 의존한다.
- 규칙이 네 곳에 있어 함께 고쳐야 한다.

## 영향 범위 (Scope)
앱 `stem_blocks.dart`, `stem_text.dart`, `passql_code_block.dart`. 웹 `stemSchemaTablePlacement.ts`, `stemBlocks.ts`, `QuestionCodeBox.tsx`. 서버 `QuestionFormatRule`. 하네스 `table_reference_linter.py`.

## 출처 (References)
- GitHub #1015 이슈 본문 「예상 동작」, 커밋 4d349dc7, #1017 커밋 34953299, PR #1018, 배포 PR #1019
- W4 충돌 검사: [[DEC-0278-stem-blocks-single-table-shape]] 「같은 컬럼 구성의 지문 표가 있으면 그 자리에」, 「첫 줄 `-- 라벨`은 상자 위 캡션」과 충돌 > **신규로 대체** (사용자 결정: #1015 이슈 본문 예상 동작, 2026-11-12). 나머지 규칙은 위 「그대로인 것」으로 이어받음.
