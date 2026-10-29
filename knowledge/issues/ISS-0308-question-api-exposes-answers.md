---
type: issue
id: ISS-0308
created: 2026-10-16
topics: [security, practice]
symptoms: [정답 노출, "GET /api/questions/{uuid}", isCorrect, rationale, answerSql, N+1, 리더보드 조작]
root_cause: "사용자용 문제 조회가 관리자용과 같은 메서드를 써서 모든 선택지 세트와 정답·해설·정답 SQL을 그대로 응답"
status: resolved
resolution: "[[ISS-0308-question-api-exposes-answers-report]]"
related: ["[[DEC-0138-solving-detail-hides-answers]]"]
source: "https://github.com/Twin-Fang/passQL/issues/503"
---

# ISS-0308: 문제 조회 API가 정답, 해설, 정답 SQL을 사용자에게 노출

GitHub #503 (원본: 이슈 본문과 댓글).

## 증상
사용자용 `GET /api/questions/{uuid}`가 문제의 모든 선택지 세트와 함께 정답 여부(`isCorrect`), 해설(`rationale`), 정답 SQL(`answerSql`)을 내려준다. 위치 `server/PQL-Domain-Question/src/main/java/com/passql/question/service/QuestionService.java:112-135`. 앱·웹은 화면에 보여주지 않지만 응답을 열면 풀기 전에 정답을 알 수 있어 오늘의 세트 순위(리더보드)와 앞으로의 모의고사 점수를 조작할 수 있다. 같은 메서드가 세트마다 항목을 따로 조회한다(N+1).

## 재현 조건
로그인 상태에서 `GET /api/questions/{문제UUID}` 호출 → 선택지 세트 항목에 `isCorrect`, `rationale`, 문제 `answerSql` 포함. 운영 API, origin/main `be840588`. 참고: GitHub #497 서버 감사 S5.

## 조사 기록
- 2026-10-16: 이슈 등록, 같은 날 수정·배포(버전 1.4.1).

## 근본 원인
관리자 화면도 같은 조회 메서드를 써서 사용자용 응답에 정답 정보가 섞였다(리포트 개요).
