---
type: issue
id: ISS-0472
created: 2026-11-07
topics: [practice, question-bank, design-system, concept-learning]
symptoms: ["지문 한 덩어리 글", "질문 문장 묻힘", "목록이 글자 - 그대로", "같은 표 두 번", "지문 표와 스키마 표 중복", "테이블 N개 카드", "N행 더 보기 접힘", "자료형 표시 섞임", "SQL 상자 회색 채움 입력 칸처럼", "코드 주석 한글 글자 간격 벌어짐", "모의고사 12번 표 중복", StemText, QuestionStemToggle, SchemaViewer, schema_table_preview.dart]
root_cause: "지문 그리기 코드(앱 StemText, 웹 QuestionStemToggle)가 지문을 한 덩어리 마크다운으로 그렸고, 스키마 표는 따로 접힌 카드로 그려 지문 표와 겹쳐도 거르지 않았다"
status: resolved
resolution: "[[ISS-0472-stem-readability-blocks-single-table-report]]"
related: ["[[DEC-0278-stem-blocks-single-table-shape]]", "[[ISS-0474-question-format-rule-forbidden-punctuation]]", "[[ISS-0455-sql-code-font-mixed-hangul]]", "[[DEC-0255-code-font-d2coding-subset]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]"]
source: "https://github.com/Twin-Fang/passQL/issues/903"
---

# ISS-0472: 문제 지문 가독성: 단락, 목록, 질문 구분과 표 한 가지 모양(PK, FK, 전체 행), SQL 상자

GitHub #903 (https://github.com/Twin-Fang/passQL/issues/903). 연습, 오늘의 세트, 모의고사, 개념 학습 지문이 모두 같은 그리기 코드를 쓰는 전 화면 공통 문제. 데이터 쪽 형식 규칙은 [[ISS-0474-question-format-rule-forbidden-punctuation]](#905). 원본 사본: `_sources/issues/ISS-0472-stem-readability-blocks-single-table.md`(로컬).

## 증상
- 소개 문장, 괄호 조건, `- 항목: 설명` 목록, 질문 문장이 같은 굵기와 간격으로 이어짐. 목록은 글머리표가 아니라 글자 `-` 그대로.
- 표가 문항마다 다른 방식: 지문 안 마크다운 표만, 아래 "테이블 1개" 영역의 스키마 표만(자료형, PK 표시, 샘플 5행 + "N행 더 보기"), 둘 다 있어 같은 표가 두 번(모의고사 12번).
- 표가 접혀 "3행 더 보기"를 눌러야 나머지 행이 보임. 행을 다 봐야 풀 수 있는 문제.
- SQL 코드 상자가 회색 채움이라 입력 칸처럼 보임. 고정폭 글꼴(D2Coding)이 한글까지 고정폭이라 주석 한글이 한 글자씩 벌어짐. 긴 SELECT 줄이 중간에서 꺾임.

## 재현 조건
모의고사 1번(목록형), 8번(정규화형), 12번(지문 표 + SQL + 같은 스키마 표) 문항 풀이 화면.

## 조사 기록
- 2026-11-07: 앱(baef13b4), 웹(33785456), 앱과 웹 규칙 맞춤(79dac311). PR #911 머지.

## 근본 원인
지문을 블록 단위로 해석하지 않고 한 덩어리로 그렸고, 스키마 표는 지문과 별개의 접힌 카드라 같은 표가 겹쳐도 거르지 못했다. 데이터 쪽에서는 문제 하네스가 지문에 표를 붙이던 것이 중복의 원인이었다(#905에서 수정).
