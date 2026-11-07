---
type: completion-report
id: ISS-0474
created: 2026-11-07
topics: [question-bank, ai, admin, concept-learning]
status: resolved
resolves: "[[ISS-0474-question-format-rule-forbidden-punctuation]]"
related: ["[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[ISS-0472-stem-readability-blocks-single-table]]"]
source: "https://github.com/Twin-Fang/passQL/issues/905"
---

# ISS-0474 완료 리포트: 형식 규칙 단일 원본(사유별 결과), 서버 금지 문자 정리기, 관리자 형식 검사 화면, 운영 데이터와 프롬프트 정리

GitHub #905 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/905#issuecomment-6702224460). 운영 데이터와 프롬프트는 먼저 반영, 코드는 PR #917 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0474-question-format-rule-forbidden-punctuation-report.md`(로컬).

## 해결 방법
- 형식 규칙 `QuestionFormatRule`, `QuestionSqlFormatRule`: 위반마다 사유, 위치, 설명, 자동 정리 가능 여부. 규칙 7개: 1) 줄표, 가운뎃점 금지 2) 데이터 표는 스키마 한 곳 3) 지문 `(PK)` 글 금지 4) 자료형 다시 적기 금지 5) SQL 서식(대문자, 긴 SELECT 줄바꿈, 한글 주석은 라벨 줄만) 6) 질문 문장 정확히 1개 7) 목록은 `- `.
- 적용: 가져오기(사유 표시, 위반 건너뜀), 관리자 저장(거부), 관리자 편집(새로 생긴 사유만 거부), 모의고사 공개 검사(경고).
- 생성 결과 정리 `ForbiddenPunctuationCleaner` 하나: 생성 보기 근거와 본문, 해설 JSON 모든 문자열, SQL 오류 해설, 통계 분석, 세션 코멘트. 짝은 `용어: 분류`, 나열은 쉼표, 함수 종속은 `→ (A, B)`, 코드 펜스와 인라인 코드 안은 보존. 동결 규칙 `server-punctuation-cleanup-single-entry`가 직접 치환을 막음. [[DEC-0277-no-dash-middle-dot-server-cleaner]].
- 관리자 `/admin/question-format`: 사유별 건수, 위반 목록(모의고사 위치), 자동 정리 미리보기, 선택 적용(감사 로그).
- 하네스: 지문에 데이터 표를 붙이던 것 제거 + lint. 개념 원본 `content/concepts` 63개 정리, 조립 도구의 가운뎃점 뒤 폭 0 공백 제거, 소제목 `## 제목: 부제`. 등록 가이드, AI 변환 안내 갱신.
- 운영(코드 머지 전): DB 정리(선택지, 해설, 지문, 개념 글 등, 약관, 회원 의견, 감사 기록, 프롬프트 이력 제외), 활성 프롬프트 12개 새 버전. 프롬프트 본문은 운영 DB에만.

## 검증
- 서버 `./gradlew build` 141개 실패 0(규칙 12개, 정리 7개). 하네스 테스트 75개, 개념 조립 63개 오류 0.
- 운영 프롬프트 테스트: 규칙 맨 끝 버전 줄표 8, 맨 앞 버전 개념형 4회와 엔터티형, SQL 실행형 모두 0.
- 운영 DB 정리 뒤 대상 칸 전수 재검사 줄표 0, 가운뎃점 0.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 새 AI 생성 경로는 저장, 응답 전에 `ForbiddenPunctuationCleaner`를 거친다. 정리 로직은 이 함수 한 곳(동결 규칙).
- 코드 펜스와 인라인 코드 안 보호를 풀면 SQL 데이터 값과 정답이 바뀔 수 있다.
- 관리자 편집은 새로 생긴 사유만 거부한다(옛 위반 문항 편집을 막지 않으려고).

## 남은 일
- 배포 뒤 운영 순서: `/admin/question-format` 사유별 건수 > 미리보기로 모의고사 문항 포함 전후 확인 > 선택 적용 > 자동으로 못 고치는 항목(실행형 지문 표, 질문 문장, SQL 서식) 손으로.
- 출시 앱은 #903 앱 배포 전까지 개념 소제목 `제목: 부제`를 한 줄로 보임(깨지지 않음).
- W4: 개념 소제목 구분자 변경은 [[DEC-0256-concept-lesson-blocks-by-table-header]] 「문단 제목」과 부분 충돌, 사용자 결정 대기.

## 교훈
LLM 문체 규칙은 프롬프트 맨 앞에 예시와 함께 둘 때 실측에서 지켜졌지만 맨 끝에서는 무시됐다. 그래도 100%가 아니므로 금지 문자는 서버 후처리로 한 번 더 막는다.
