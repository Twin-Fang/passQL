---
type: decision
id: DEC-0320
created: 2026-11-16
reviewed: null
topics: [practice, admin]
status: active
supersedes: DEC-0316
superseded_by: null
related: ["[[ISS-0523-exam-answer-disputed-shows-operator-candidate]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[DEC-0317-site-answer-key-fallback-operator-draft]]"]
---

# DEC-0320: 가답안 표시 정답은 운영 가답안(LEADING·CONFIRMED·OFFICIAL, 갈림 DISPUTED 의 후보 답 포함) 우선·없으면 득표 1위이며, 확정 채점은 LEADING·CONFIRMED·OFFICIAL 만 하고 갈림은 점수 범위로 둔다

GitHub #1101 (이슈 본문, 서버 커밋 1a53215c, PR #1103, 보고서 댓글). [[DEC-0316-exam-answer-two-sources-operator-first]]를 대체한다 — 바뀐 것은 "표시 정답" 한 항목이고 나머지는 그대로 옮겼다.

## 문제 정의 (Context)
DEC-0316 규칙에서는 운영 가답안 상태가 갈림(DISPUTED)이면 운영 후보 답이 있어도 득표 1위만 보였다. 시험 직후처럼 가채점 참여가 적으면 득표가 없어 정답이 "?"로 보였고, 63회는 15문항이 해당했다(이슈 본문).

## 결정 (Decision)
- **출처 2개 (변경 없음):** ① 운영 가답안 — 상태 `UNKNOWN`·`LEADING`(우세)·`DISPUTED`(갈림)·`CONFIRMED`·`OFFICIAL`. ② passQL 사용자 OMR 제출 집계.
- **표시 정답 (변경):** 운영 답이 유효(1~4)하고 상태가 `LEADING`·`CONFIRMED`·`OFFICIAL`·`DISPUTED` 이면 운영 답, 아니면 득표 1위, 득표도 없으면 null. `UNKNOWN` 은 운영 답이 저장돼 있어도 득표 1위.
- **확정 채점 (변경 없음):** `LEADING`·`CONFIRMED`·`OFFICIAL` 만 확정. 갈림은 표시만 운영 후보 답이고 미확정 문항으로 점수 범위에 들어간다. 코드에서 두 판정을 분리 — `ExamAnswerItemStatus.isOperatorAnswerTrusted()`(채점) <-> `isOperatorCandidateShown()`(표시).
- **득표 집계·상위 %·점수 범위·채점 규칙 (변경 없음):** 회차 스냅샷 60초 캐시, 참여 10명 미만이면 상위 % 비움, 미확정 문항 최저·최고로 PASS / FAIL / BORDERLINE, SQLD 공식 기준(서버 `gradingRule` 이 원본).

## 검토한 대안 (Alternatives)
- 갈림 문항도 운영 답으로 확정 채점: 하지 않음 — 이슈 본문 "채점은 바꾸지 않는다. 갈림 문항은 계속 확정되지 않은 문항으로 보고 점수 범위로 계산한다".
- 기존 유지(갈림은 득표 1위): 참여 적을 때 "?"가 보이는 문제 때문에 사용자가 변경 승인("해줘").

## 결과 (Consequences)
**긍정**
- 공개 API `GET /api/exam-answers/SQLD/63` 실측: 갈림 15문항 중 운영 후보 답이 있는 13문항이 그 답으로 표시, 정답 빈 문항은 29번(미복원)·47번(후보 없음)만.
- 채점 결과(점수 범위)는 이전과 같다.

**부정**
- 화면에 숫자가 보이므로 클라이언트가 "갈림" 표시를 빼면 확정 정답처럼 오해될 수 있다.

## 영향 범위 (Scope)
서버 `submission/constant/ExamAnswerItemStatus`, `submission/service/ExamAnswerKeyResolver`(+ `ExamAnswerKeyResolverTest` 3개), `dto/examanswer/ExamAnswerItemResponse` 설명, `api-contract/openapi.json`, `client/src/types/generated/openapi.ts`. 앱 코드 변경 없음(서버 응답 `answer` 를 그대로 표시). 소개 사이트는 서버 스냅샷으로 재배포.

## 출처 (References)
- GitHub #1101 https://github.com/Twin-Fang/passQL/issues/1101
- 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1101#issuecomment-6897051400

## W4 검사
- [[DEC-0316-exam-answer-two-sources-operator-first]]: 표시 정답 규칙이 충돌 > 사용자 결정 "신규로 대체"(#1101 승인). DEC-0316 은 superseded, 본문 유지.
- [[DEC-0317-site-answer-key-fallback-operator-draft]]: 서버 실패 시 사이트 스냅샷 대체 규칙 — 대상이 달라 충돌 없음.
