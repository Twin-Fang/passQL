---
type: completion-report
id: ISS-0308
created: 2026-10-16
topics: [security, practice]
status: resolved
resolves: "[[ISS-0308-question-api-exposes-answers]]"
related: ["[[DEC-0138-solving-detail-hides-answers]]"]
source: "https://github.com/Twin-Fang/passQL/issues/503"
---

# ISS-0308 완료 리포트: 풀이용·관리자용 문제 조회 분리로 정답 노출 차단

GitHub #503 구현 보고서 댓글 기준 (2026-10-16, Spring run `38886597723`, 버전 1.4.1).

## 해결 방법
- `QuestionService.getQuestionForSolving`(신규): `answerSql`은 `null`, 선택지 세트는 최신 OK 세트 1개만, 항목의 정답 여부·해설은 `null`.
- `QuestionService.getQuestionForAdmin`(기존 `getQuestion` 이름 변경): 모든 세트와 정답·해설·정답 SQL 포함.
- `QuestionController`는 풀이용, `AdminQuestionController`는 관리자용 사용. 변환 메서드 `toChoiceSetSummary`, `toQuestionDetail`은 정답 포함 여부를 인자로 받음.
- `QuestionControllerDocs`, `api-contract/openapi.json`, 웹 생성 타입 갱신(응답 형태는 그대로).
- 세트별 항목 조회(N+1)가 1회로 줄었다.

## 근본 원인 (확정)
사용자용·관리자용 조회가 한 메서드였다.

## 재발 방지
- `QuestionDetailAnswerExposureTest`(신규 2개)가 풀이용에서 정답이 빠지고 관리자용에는 남는지 검증.
- 운영 실측: 임의 회원 UUID 토큰으로 조회 → `answerSql=None`, `choiceSets=1`, 항목 4개, `isCorrect`·`rationale` 모두 `None`.
- 주의사항: 정답과 해설은 제출 응답에서만 내려간다. 풀기 전에 정답이 필요하다는 요구가 생겨도 이 API에 다시 넣지 말고 서버 채점을 거치게 한다.
- 남은 것: 웹 `client/src/pages/DailyChallenge.tsx`(라우트 미연결)는 선택지 `isCorrect`로 오답을 판정하므로 다시 쓰려면 제출 API로 바꿔야 한다. 운영 DB에 테스트 계정(`is_test_account`)이 없다.

## 교훈
(원본에 없음, 볼트 정리) 사용자 응답 DTO에 정답 필드가 nullable로 남아 있으면 같은 조회를 관리자와 공유하는 순간 노출된다 — 사용자용 조회 경로를 따로 둔다.
