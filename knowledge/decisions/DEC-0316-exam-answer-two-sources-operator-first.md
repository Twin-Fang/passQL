---
type: decision
id: DEC-0316
created: 2026-11-14
reviewed: null
topics: [practice, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]", "[[DEC-0315-exam-answer-page-concept-line-no-original]]"]
---

# DEC-0316: 가답안 출처는 운영 가답안과 사용자 OMR 집계 2개이고, 표시 정답은 운영 가답안 우선·없으면 득표 1위이며, 득표는 60초 캐시, 참여 10명 미만이면 상위 %를 숨긴다

GitHub #1075 (설계 스펙, 서버 커밋 d6b610a3, 보고서 댓글).

## 문제 정의 (Context)
회차 가답안을 어디서 가져와 어떤 정답을 보여 줄지, 가채점의 상위 %를 언제 보여 줄지 정해야 했다. 시험 당일에는 공식 정답이 없고, 복원 사이트들은 보기별 득표·합의율이 없거나 가답안이 보이지 않았다(이슈 본문).

## 결정 (Decision)
- **출처 2개:** ① 운영 가답안 — 관리자가 수집 자료로 입력, 상태 `UNKNOWN`·`LEADING`(우세)·`DISPUTED`(갈림)·`CONFIRMED`·`OFFICIAL`. ② passQL 사용자 OMR 제출 집계(우리 데이터).
- **표시 정답:** 운영 가답안이 있으면 그것, 없으면 득표 1위(`ExamAnswerKeyResolver`). 공식 정답 발표 시 관리자에서 50자 일괄 입력 > `OFFICIAL`.
- **득표 집계:** 조회 시 계산하고 회차 스냅샷을 60초 캐시(`ExamAnswerSnapshotCache`).
- **상위 %:** 참여 10명 미만이면 비움 — 모의고사 순위와 같은 기준(`MockExamRankingCalculator.MINIMUM_RANKING_TAKER_COUNT`).
- **점수 범위:** 확정 안 된 문항을 틀림/맞음으로 가정한 최저·최고로 PASS / FAIL / BORDERLINE.
- **채점 규칙:** SQLD 공식 기준(50문항, 문항당 2점, 60점 합격, 과목별 40% 미만 과락). 서버 응답 `gradingRule` 이 원본, 앱 상수는 오프라인 대체용.

## 검토한 대안 (Alternatives)
- 경쟁 사이트 데이터 자동 동기화: 하지 않음(스펙 "하지 않는 것"). 이유는 논의 기록 없음.
- 60초라는 캐시 길이, 10명 기준 외 다른 값 검토: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 참여자가 적은 시험 당일 초반에도 운영 가답안으로 표를 채우고, 참여가 늘면 득표·합의율이 붙는다.
- 상위 %가 소수 표본으로 왜곡돼 보이지 않는다.

**부정**
- 운영 가답안 입력이 늦으면 서버는 미확정으로 응답한다(배포 직후 입력 필요, [[ISS-0520-sqld-round-answer-key-omr-grading]] 남은 일).
- 득표·참여자 수는 최대 60초 늦게 반영된다.

## 영향 범위 (Scope)
서버 `submission/service/ExamAnswer*`, `submission/entity/ExamAnswer*`, Flyway `V1_128_1__exam_answer_key.sql`, `MemberApiRateLimitRule`(제출 분당 30·내 답안 60·회차 120), 관리자 `/admin/exam-answers`, 앱 `core/exam_answer/*`·`data/exam_answer/*`, `api-contract/openapi.json`.

## 출처 (References)
- GitHub #1075 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6875720871
- 설계 스펙 `docs/superpowers/specs/2026-11-14-exam-answer-key-design.md` (로컬 전용)

## W4 검사
[[DEC-0264-mock-exam-fixed-rounds-server-judged]]는 유료 모의고사의 서버 판정(타이머·채점·응시 수)을 정한 결정이다. 가채점은 공개·비로그인 기능이고 앱의 기기 채점은 네트워크 실패 시 대체일 뿐이라 대상이 다르다 — 충돌 없음. 합격·과락 기준은 같은 공식 기준을 쓴다.
