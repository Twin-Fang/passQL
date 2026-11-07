---
type: decision
id: DEC-0277
created: 2026-11-07
reviewed: null
topics: [question-bank, ai, concept-learning]
status: active
supersedes: DEC-0256
superseded_by: null
related: ["[[ISS-0474-question-format-rule-forbidden-punctuation]]", "[[ISS-0474-question-format-rule-forbidden-punctuation-report]]", "[[DEC-0278-stem-blocks-single-table-shape]]", "[[DEC-0076-markdown-rules-for-generated-content]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]", "[[DEC-0265-prompt-key-enum-single-source]]"]
---

# DEC-0277: 문항과 생성 글에 줄표와 가운뎃점을 쓰지 않고(짝은 "용어: 분류", 나열은 쉼표, 함수 종속은 "→ (A, B)"), 생성 프롬프트 맨 앞 규칙에 더해 서버가 저장, 응답 전에 ForbiddenPunctuationCleaner 로 한 번 더 정리하며, 데이터 표는 스키마 표 한 곳에만 둔다

## 문제 정의 (Context)
문항, 보기, 해설, 개념 글에 줄표와 가운뎃점 나열이 많아 AI가 쓴 티가 났고, 문항 내용 형식 규칙이 코드 어디에도 없어 들어오는 길마다 형식이 달랐다. 표는 지문 마크다운 표와 스키마 표로 섞여 같은 표가 두 번 나왔다 (GitHub #905, [[ISS-0474-question-format-rule-forbidden-punctuation]]).

## 결정 (Decision)
- **금지 문자:** 줄표 3종(em dash, en dash, 가로 막대)과 가운뎃점을 지문, 보기, 해설, 개념 글, AI 생성 글에 쓰지 않는다. 쉼표는 허용(사용자 확인 기준).
- **바꾸는 모양:** 짝은 `용어: 분류`, 나열은 `A, B, C`, 함수 종속은 묶음 경계를 지키려고 `주문번호 → (주문일자, 고객번호)`처럼 괄호. 코드 펜스와 인라인 코드 안은 바꾸지 않는다(SQL 데이터 값 보호).
- **생성 쪽 두 겹:** 운영 DB 생성 프롬프트 맨 앞에 문체 규칙과 올바른 예를 두고(프롬프트 본문은 운영 DB에만), 서버가 AI 생성 결과(보기 근거와 본문, 해설 JSON 모든 문자열, SQL 오류 해설, 통계 분석, 세션 코멘트)를 저장하거나 응답하기 전에 `ForbiddenPunctuationCleaner` 하나로 다시 정리한다. 다른 곳에서 직접 치환하는 것은 동결 규칙 `server-punctuation-cleanup-single-entry`로 막는다.
- **등록 쪽:** 문항 형식 규칙 단일 원본 `QuestionFormatRule`(사유별 결과, 규칙 7개)을 가져오기(위반 건너뜀), 관리자 저장(거부), 관리자 편집(새로 생긴 사유만 거부), 모의고사 공개 검사(경고)가 거친다.
- **데이터 표는 스키마 표 한 곳:** 데이터가 있는 표는 스키마 표(컬럼, PK, FK, 행)로만 둔다. 같은 컬럼의 지문 표, `[EMP]` 머리말 지문 표는 위반. 문제 하네스는 지문에 데이터 표를 붙이지 않는다(lint).
- **개념 글 소제목:** `## 제목: 부제` (구분자 `: `). 운영 개념 글 소제목 447곳과 레포 원본 63개를 바꿨고, 앱 해석기는 `: `와 옛 줄표 구분자를 모두 읽는다(#903). [[DEC-0256-concept-lesson-blocks-by-table-header]]의 문단 제목 표기를 대체한다.
- **DEC-0256에서 그대로인 것:** 개념 글은 내용 유형별 레슨 블록(정의와 용어는 용어 카드, 순서는 단계와 두문자 외우는 법, 분류와 비슷한 쌍은 비교 표, 규칙과 함정은 헷갈리는 말 + OX 바로 확인, SQL 은 풀이 예시), 블록은 표 머리글(`용어 | 뜻`, `단계 | 내용`, `외우기 | 뜻`, `헷갈리는 말 | 실제로는`, `바로 확인 | 정답 | 이유`)로 구분, 글 문단 2문장 이내, 외우는 법은 사실 검증한 것만, 긴 문단 접기 없음, 스크롤 등장(동작 줄이기면 정지).

## 검토한 대안 (Alternatives)
- 프롬프트 규칙만으로 막기: 운영 실측에서 규칙을 프롬프트 맨 끝에 둔 버전이 다른 줄표를 8번 썼다. 규칙을 맨 앞으로 옮기고 예시를 넣자 0건이었지만 100% 보장이 안 되어 서버 정리를 필수로 넣었다 (#905 운영 반영 댓글, 구현 확인 댓글).
- 그 밖의 대안 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 생성 경로가 늘어도 금지 문자가 한 함수에서 걸러지고, 등록 형식이 사유별로 안내된다.

**부정 / 조건**
- 새 AI 생성 경로는 반드시 정리기를 거쳐야 한다. 코드 안 보호를 풀면 SQL 정답이 바뀔 수 있다.
- 자동으로 못 고치는 항목(실행형 지문 표, 질문 문장, SQL 서식)은 관리자가 손으로 정리해야 한다.
- 출시 앱은 #903 앱 배포 전까지 개념 소제목 `제목: 부제`를 한 줄로 보인다(깨지지 않음).

## 영향 범위 (Scope)
서버 `ForbiddenPunctuationCleaner`, `QuestionFormatRule`, `QuestionSqlFormatRule`, `QuestionFormatAutoFixer`, `ChoiceSetSaveService`, `AiExplanationGenerator`, `ChoiceExplanationService`, `AiAnalysisInsightParser`, `QuestionImportItemValidator`, `MockExamPublishChecker`, 관리자 `/admin/question-format`, 등록 가이드. `tools/sqld-question-harness`, `content/concepts` 63개. 운영 DB 데이터와 활성 프롬프트 12개.

## 출처 (References)
- GitHub #905 이슈 본문, 운영 반영 댓글, 코드 구현 확인 댓글, 리포트 댓글 (2026-11-07), PR #917
- W4 충돌 검사: [[DEC-0076-markdown-rules-for-generated-content]](마크다운 활용 규칙), [[DEC-0265-prompt-key-enum-single-source]]와 충돌 없음. [[DEC-0256-concept-lesson-blocks-by-table-header]] 「문단 제목은 제목 줄표 부제」와 부분 충돌 > **신규로 대체** (사용자 결정, 2026-11-07). 근거: 사용자 "AI 는 ㅡ 이런 거 적거든, 안 적게 처리해", 운영 개념 글 소제목 447곳을 `제목: 부제`로 바꿈.
