---
type: decision
id: DEC-0278
created: 2026-11-07
reviewed: null
topics: [practice, question-bank, design-system, concept-learning]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0472-stem-readability-blocks-single-table]]", "[[ISS-0472-stem-readability-blocks-single-table-report]]", "[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[DEC-0255-code-font-d2coding-subset]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]", "[[DEC-0074-shared-markdowntext-component]]"]
---

# DEC-0278: 문제 지문은 블록(단락, 보조 설명, 질문, 목록, 표, 코드)으로 나눠 앱과 웹이 같은 규칙으로 그리고, 표는 지문 카드 안 한 가지 모양(컬럼 이름 + PK, FK, 행 전부, 자료형과 샘플 표시 없음)으로 같은 컬럼 표는 한 번만 그린다

## 문제 정의 (Context)
지문이 한 덩어리 글로 그려져 무엇을 묻는지 바로 보이지 않았다. 표는 지문 마크다운 표, 접힌 "테이블 N개" 스키마 카드, 둘 다로 섞여 같은 표가 두 번 나왔고, "N행 더 보기"로 접혀 행을 다 봐야 하는 문제에서 불편했다. SQL 상자는 회색 채움이라 입력 칸처럼 보였다 (GitHub #903, [[ISS-0472-stem-readability-blocks-single-table]]).

## 결정 (Decision)
- **블록:** 지문을 줄 단위로 단락, 보조 설명(줄 전체가 괄호, 괄호 유지), 질문(`?`로 끝남, 순서 유지하고 강조), 목록(`- `, `• `, 번호로 시작하는 연속 줄, `용어: 설명`이면 용어 굵게, 번호 목록은 번호 유지), 표, 코드로 나눈다.
- **같은 규칙 두 구현:** 앱 `stem_blocks.dart`, 웹 `client/src/lib/stemBlocks.ts`가 같은 계약을 따른다. 판정 최소 테스트를 양쪽에 둔다.
- **표 한 가지 모양:** 지문 표와 스키마 표를 같은 표 컴포넌트로 지문 카드 안에 그린다. 머리글은 컬럼 이름 + PK, FK 표시만, 행 전부, 자료형과 "샘플 N행", "N행 더 보기" 없음. 같은 컬럼 구성의 지문 표가 있으면 그 자리에 스키마 표를 한 번만. 풀이 화면의 별도 "테이블 N개" 카드는 없앤다(DDL 원문만 있는 문항 제외). 자료형이 풀이에 필요한 문제는 지문에 적는다.
- **SQL 상자:** 채움 대신 얇은 테두리, 첫 줄 `-- 라벨`은 상자 위 캡션(본문 글꼴), 코드 속 한글 덩어리는 본문 글꼴, 웹 긴 줄은 가로 스크롤.
- **개념 글 소제목:** 부제 구분자는 `: `(해석기는 옛 줄표 구분자도 읽음). [[DEC-0277-no-dash-middle-dot-server-cleaner]]의 콘텐츠 정리와 짝.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 「해결 방안」이 블록 4종, 표 한 가지 모양, SQL 상자 규칙을 시안 캡처와 함께 처음부터 제시. 구현 중 앱과 웹을 맞추며 번호 목록 번호 유지, 보조 설명 괄호 유지로 정함.)

## 결과 (Consequences)
**긍정**
- 질문과 조건이 눈에 띄고, 표는 한 번, 행 전부로 보인다. 앱과 웹 지문이 같다.

**부정 / 조건**
- 블록 규칙이 앱과 웹 두 곳에 있어 함께 고쳐야 한다.
- 중복 표 판정은 컬럼 구성 비교라 컬럼 이름이 다르면 두 번 그려진다.
- 웹은 다크 모드가 없어 라이트만 확인했다.

## 영향 범위 (Scope)
앱 `stem_blocks.dart`, `stem_text.dart`, `question_data_table.dart`, `schema_table_preview.dart`, `passql_code_block.dart`, `concept_reading_parser.dart`, `question_solving_body.dart`, `mock_exam_question_view.dart`. 웹 `stemBlocks.ts`, `stemSchemaTablePlacement.ts`, `StemBlocks.tsx`, `QuestionTable.tsx`, `QuestionCodeBox.tsx`, `SchemaViewer.tsx`, `QuestionStemToggle.tsx`, `question-stem.css`.

## 출처 (References)
- GitHub #903 이슈 본문, 앱과 웹 구현 확인 댓글, 리포트 댓글 (2026-11-07), PR #911
- W4 충돌 검사:
  - [[DEC-0074-shared-markdowntext-component]]: 웹 지문 블록 안 글은 인라인 마크다운 컴포넌트로 그려 충돌 없음.
  - **[[DEC-0255-code-font-d2coding-subset]] 「코드 글꼴은 한글까지 고정폭 D2Coding」과 부분 충돌**: 지문 SQL 상자의 코드 속 한글 덩어리를 본문 글꼴로 바꿨다(#903 이슈 본문 "한글은 본문 글꼴로 그려 글자 간격이 벌어지지 않게").
  - **[[DEC-0256-concept-lesson-blocks-by-table-header]] 「문단 제목은 제목 줄표 부제」와 부분 충돌**: 구분자 `: `.
  - 두 노트는 이 노트 작성 시점에 active 로 두었고, 처리(대체 또는 조건부 유지)는 사용자 결정 대기.
