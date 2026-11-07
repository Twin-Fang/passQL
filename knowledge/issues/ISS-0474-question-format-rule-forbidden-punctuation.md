---
type: issue
id: ISS-0474
created: 2026-11-07
topics: [question-bank, ai, admin, concept-learning]
symptoms: ["줄표 AI 티", "em dash en dash 보기", "가운뎃점 나열", "짝 보기 줄표", "문항 형식 제각각", "지문 마크다운 표와 스키마 표 중복", "PK 표시 불일치", "자료형 표시 섞임", "긴 SELECT 한 줄", "코드 안 한글 주석", "질문 문장 지문 중간", "프롬프트 규칙 무시 다른 줄표", "개념 소제목 부제 구분자", QuestionFormatRule, ForbiddenPunctuationCleaner, QuestionImportItemValidator, quality_linter.py, import_exporter.py]
root_cause: "문제 가져오기 검증과 생성 경로에 내용 형식 규칙이 없었고, 문제 하네스가 지문에 데이터 표를 붙였으며, 프롬프트 지시만으로는 LLM 이 금지 문자를 계속 썼다"
status: resolved
resolution: "[[ISS-0474-question-format-rule-forbidden-punctuation-report]]"
related: ["[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[ISS-0472-stem-readability-blocks-single-table]]", "[[DEC-0076-markdown-rules-for-generated-content]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]"]
source: "https://github.com/Twin-Fang/passQL/issues/905"
---

# ISS-0474: 문제 만드는 하네스 형식 규칙: 줄표 금지, 표는 스키마 한 곳, SQL 서식, 기존 데이터 정리

GitHub #905 (https://github.com/Twin-Fang/passQL/issues/905). 화면 쪽은 [[ISS-0472-stem-readability-blocks-single-table]](#903). 원본 사본: `_sources/issues/ISS-0474-question-format-rule-forbidden-punctuation.md`(로컬).

## 증상
- 가져오기 검증은 필수 필드, 토픽, 실행 모드, Oracle 문법, 샌드박스 실행만 보고 내용 형식은 보지 않음. 문항마다 형식이 제각각이고 AI가 쓴 티가 남.
- 줄표 사용(짝 보기 "용어 줄표 분류", 해설 문장 안 줄표). 시드 데이터에만 17곳.
- 표를 넣는 방식이 문항마다 다름(지문 마크다운 표, 스키마 표, 둘 다). PK, FK 표시 불일치, 자료형 표시 섞임.
- SQL 서식: 긴 SELECT 목록 한 줄, 코드 안 한글 설명 주석. 질문 문장이 지문 중간에 묻힘.
- 운영 실측: 규칙을 프롬프트 맨 끝에 둔 버전에서 LLM이 다른 줄표(en dash)를 8번 씀.

## 재현 조건
운영 문항, 보기, 해설, 개념 글 전반. 생성 경로는 관리자 프롬프트 테스트(실제 LLM 호출)로 확인.

## 조사 기록
- 2026-11-07: 사용자 확인 기준 "줄표 3종과 가운뎃점 금지, 쉼표 허용". 운영 DB 데이터 정리(백업, 한 트랜잭션, 0건 재검사 뒤 커밋), 활성 프롬프트 12개 새 버전(규칙 맨 앞 + 올바른 예).
- 2026-11-07: 코드 95295863(형식 규칙, 정리기, 관리자 화면, 하네스), 7759c888(개념 원본 63개, 소제목 `: `). PR #917 머지.

## 근본 원인
내용 형식 규칙이 코드 어디에도 없어 들어오는 길(가져오기, 관리자 저장, AI 생성)마다 형식이 달랐다. 표 중복은 문제 하네스가 지문에 `[T]` 표를 붙이던 것이 원인. 생성 결과의 금지 문자는 프롬프트 지시만으로는 막히지 않았다.
