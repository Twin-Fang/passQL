---
type: decision
id: DEC-0301
created: 2026-11-13
reviewed: null
topics: [practice, progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0511-qa-1112-ui-polish-eight]]", "[[ISS-0511-qa-1112-ui-polish-eight-report]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0301: 모의고사 결과에 같은 회차 응시자 중 "상위 N%" 한 줄을 보이고, 순위는 회원별 그 회차 첫 응시 점수로만 세며 응시자 10명 미만이면 숨기고 무료도 공개한다

GitHub #1041 (이슈 본문 3번, 「시안 8건」 댓글 ③, 완료 보고서).

## 문제 정의 (Context)
모의고사 결과 화면에 내 점수만 있어 같은 회차 응시자 사이에서 내 위치를 알 수 없었다(11/12 QA 요청, 해석은 이슈 본문).

## 결정 (Decision)
- **표시:** 결과 점수 아래 한 줄 `상위 N%` + `이 회차 응시자 N명 중 M위`. 다른 사람 점수는 보이지 않는다.
- **기준:** 회원별 그 회차 **첫 응시** 점수만 센다(재응시로 순위를 올리지 못하게). 재응시 결과를 볼 때도 분포는 다른 회원의 첫 응시이고 내 자리에만 지금 점수를 넣는다.
- **계산:** 순위 = 나보다 높은 회원 수 + 1(동점 같은 순위), 상위 % = 올림, 1~100.
- **숨김:** 응시자(나 포함) 10명 미만이면 `ranking = null` > 앱은 줄을 숨긴다(`MINIMUM_RANKING_TAKER_COUNT = 10`).
- **등급:** 무료도 공개. [[DEC-0264-mock-exam-fixed-rounds-server-judged]]의 무료 범위(총점·합격 여부·정오)에 순위 한 줄을 더하는 것이며 그 밖의 경계는 그대로.
- **구현 위치:** 서버가 판정(`MockExamRankingCalculator` 순수 함수, 회차 제출 응시를 쿼리 1번으로 읽어 코드에서 고름), 응답 `MockExamResultResponse.ranking`(nullable).

## 검토한 대안 (Alternatives)
- B안 점수 분포 막대 + 내 위치: 정보는 많지만 화면 하나가 늘고, 응시자가 적은 동안 막대가 들쭉날쭉(시안 댓글 이미지 설명).
- C안 순위표: 세트 순위와 같은 모양이지만 모의고사는 응시자가 적고 다른 사람 점수 노출이 부담(시안 댓글 이미지 설명).
- 쿼리에서 회원별 첫 응시를 고르는 방식: 서버에 DB 통합 테스트 환경이 없어 단위 테스트로 검증하려고 코드 계산을 택함. 응시가 크게 늘면 쿼리 방식으로 바꾼다(리포트 주의사항).
- 무료 공개 여부를 두고 다른 안을 검토한 기록은 없다(논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 작은 공간 한 줄, 다른 사람 점수 노출 없음(시안 댓글 추천 이유).

**부정**
- 회차의 제출 응시를 전부 읽어 메모리에서 고른다(응시가 늘면 비용 증가).
- 서버 배포 전·구버전 서버에서는 순위가 보이지 않는다.

## 영향 범위 (Scope)
서버 `MockExamRanking`, `MockExamResultResponse`, `MockExamAttemptRepository.findSubmittedScoresByRoundInSubmitOrder`, `MockExamRankingCalculator`, `api-contract/openapi.json`, 웹 생성 타입. 앱 모의고사 결과 점수 머리.

## 출처 (References)
- GitHub #1041 이슈 본문, 시안 댓글 ③, 완료 보고서 댓글, PR #1042
- [[ISS-0511-qa-1112-ui-polish-eight-report]]
