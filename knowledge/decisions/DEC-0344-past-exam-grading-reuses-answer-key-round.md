---
type: decision
id: DEC-0344
created: 2026-11-17
reviewed: null
topics: [practice, question-bank, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0542-past-exam-grading-omr-link]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]"]
---

# DEC-0344: 지난 회차 가채점은 새 모델 없이 가답안 회차를 더해 재사용하고, 진입은 기출 복원 탭, 정답은 확정(CONFIRMED)으로 넣어 득표를 숨긴다

## 문제 정의 (Context)
63회 가답안·OMR 가채점을 지난 회차에도 열어야 했다([[ISS-0542-past-exam-grading-omr-link]]). 지난 회차 정답은 공식 발표가 아니라 응시자 복원 자료라는 점과, 기출 풀이는 최근 1회차만 무료([[DEC-0328-past-exam-rewrite-operation-rules]])라는 점을 함께 다뤄야 했다.

## 결정 (Decision)
- 가답안 회차 행을 회차마다 더해 기존 API·화면을 재사용한다(새 테이블·API 없음). 서버는 기출 회차 응답에 `hasExamAnswerKey` 만 더한다.
- 진입은 기출 복원 탭 맨 위 [지난 회차 가채점] 행 > 회차 시트. 열린 회차가 없으면 숨긴다.
- 지난 회차 = 회차 상태 OFFICIAL + 시험일 7일 초과(홈 강조 기간 [[DEC-0327-answer-key-highlight-exam-date-plus-7]] 와 같은 값). 이때 득표·합의율·참여자 수를 숨기고 "복원 자료 기준 정답"으로 표기, [이 회차 기출 풀기]로 잇는다.
- 복원 정답은 문항 상태 CONFIRMED 로 넣는다(공식 발표 아님, 면책 유지). 가채점 API 는 로그인 불필요를 유지하고 기출 풀이 PRO 경계는 바꾸지 않는다.
- 정답 운영 입력은 로컬 스크립트(점검 기본, `--execute`, 백업, `--rollback` = CLOSED + 문항 비움)로만 하고 운영 쓰기는 사용자가 한다.

## 검토한 대안 (Alternatives)
- 지난 회차 판정을 서버 필드로 내려주기, 별도 RESTORED 상태 추가: 서버 enum·앱 변경이 커서 보류. 사용자 논의 기록 없음(구현 중 판단).
- 모든 회차 가채점을 무료로 열지 여부, 복원 사이트 표기 정답 사용 여부: 사용자 확인 필요(미결).

## 결과 (Consequences)
**긍정**
- 새 모델 없이 지난 회차 18개를 같은 화면으로 가채점한다. 데이터가 없으면 화면 변화가 없어 배포가 안전하다.

**부정**
- 회차 상태 OFFICIAL 이 복원 정답에도 쓰여 이름이 실제와 어긋난다(앱 문구로 보완).
- 정답 출처가 복원 자료라 틀릴 수 있다. 45~57회 정답은 확보 방법이 없다.

## 영향 범위 (Scope)
서버 `MockExamRoundQueryService`·`MockExamRoundListResponse`, 앱 `mock_exam_past_grading_entry.dart`·가답안 화면·`ExamAnswerDisplayRule`, `tools/past-exam-answer-key/`.

## 출처 (References)
- GitHub #1151 https://github.com/Twin-Fang/passQL/issues/1151, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1151#issuecomment-6937030195

## W4 검사
- DEC-0327: 같은 기준(시험일 + 7일) 재사용, 충돌 없음. DEC-0328: 기출 풀이 무료 경계를 바꾸지 않음, 충돌 없음. DEC-0315(원문 비게시): 개념 한 줄만 써 충돌 없음. DEC-0316(운영 가답안 우선): 같은 방향.
