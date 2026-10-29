---
type: decision
id: DEC-0138
created: 2026-10-16
reviewed: null
topics: [security, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0308-question-api-exposes-answers]]", "[[ISS-0308-question-api-exposes-answers-report]]"]
---

# DEC-0138: 사용자용 문제 상세는 응답 형태를 유지한 채 정답 필드를 비우고 최신 OK 세트 1개만 보낸다

## 문제 정의 (Context)
사용자용 `GET /api/questions/{uuid}`가 정답 여부·해설·정답 SQL을 내려줘 순위·모의고사 점수 조작이 가능했다 (GitHub #503).

## 결정 (Decision)
- 풀이용 조회(`getQuestionForSolving`)와 관리자용 조회(`getQuestionForAdmin`)를 나눈다.
- 풀이용 응답은 형태를 바꾸지 않고 `answerSql`, 항목의 `isCorrect`·`rationale`을 `null`로 보낸다.
- 선택지 세트는 최신 OK 세트 1개만 보낸다.
- 정답과 해설은 제출 응답에서만 내려간다. 세트 목록과 정답 정보는 관리자 API로만 조회한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (원본 "왜 이 방식인가"는 응답 형태 유지와 세트 1개 전송의 이유만 적었다.)

## 결과 (Consequences)
**긍정**
- 해당 필드가 원래 nullable이라 앱(freezed 모델)·웹(생성 타입)을 바꾸지 않아도 되고, 이미 설치된 앱 1.2.x도 그대로 동작한다.
- 앱·웹은 원래 첫 OK 세트만 썼으므로 결과가 같고, 세트별 항목 조회(N+1)가 1회로 줄었다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`QuestionService`, `QuestionController`, `AdminQuestionController`, `api-contract/openapi.json`, 웹 생성 타입. (참고: 선택지 생성 응답에서 정답을 빼는 기존 결정 DEC-0040과 같은 방향.)

## 출처 (References)
- GitHub #503 구현 보고서 댓글 (2026-10-16)
- [[ISS-0308-question-api-exposes-answers]]
