---
type: issue
id: ISS-0538
created: 2026-11-16
topics: [practice, progress-stats, design-system, admin]
symptoms: ["0점인데 20명 중 4위", "상위 20%", "모의고사 순위 부풀림", "빈 답안 응시자 집계", "시간 종료 빈 제출", "MockExamRankingCalculator", "findSubmittedScoresByRoundInSubmitOrder", "합의 100% 응답 1명", "가채점 제출 후 참여 수 그대로", "공유 이미지 다크 검은 바탕", "exam_answer_share_card", "주황 메모 상자", "가답안 가답안 중복 제목", "테스트 답안지 삭제 불가", "모의고사 결과 큰 X 원 알약 칩"]
root_cause: "모의고사 순위 쿼리가 한 문항도 고르지 않은 빈 답안(시간 종료·바로 제출)까지 응시자로 세어 0점 동점 무리 속에서 0점이 좋은 순위로 보였다; 나머지는 실기 검수에서 드러난 표시·갱신 결함"
status: resolved
resolution: "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking-report]]"
related: ["[[DEC-0332-exam-answer-share-image-always-light]]", "[[DEC-0333-mock-exam-ranking-excludes-empty-attempts]]", "[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]", "[[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]", "[[ISS-0524-exam-answer-screen-no-card-chip-gradient]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[ISS-0511-qa-1112-ui-polish-eight]]"]
source: "_sources/issues/ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking.md"
---

# ISS-0538: SQLD 63회 가답안·모의고사 결과 실기 검수 결함 7건 (빈 답안이 순위 응시자로 집계)

GitHub #1126. 원본 URL: https://github.com/Twin-Fang/passQL/issues/1126

## 증상
SQLD 제63회 가답안·가채점 실기 검수(iOS 시뮬레이터 라이트/다크)에서 나온 결함 7건.
1. (앱) 가채점 제출 후 홈 가답안 구간 참여 수가 그대로
2. (앱·소개 사이트) 응답 1~2명인 갈림 문항에 "합의 100%"
3. (앱) 가답안 펼침 안 주황 "메모" 상자가 카드 안 카드처럼 보임
4. (앱) 다크 모드에서 공유 이미지(미리보기·저장 이미지)가 검은 바탕
5. (서버) 모의고사 0점 제출 결과가 "20명 중 4위, 상위 20%" — 응답 발췌 `"totalScore":0, ... "ranking":{"rankPosition":4,"takerCount":20,"topPercent":20}`
6. (앱) 모의고사 결과 상단의 큰 빨간 X 원·알약 칩이 가답안 결과 화면과 디자인 언어가 다름
7. (서버·관리자) 테스트로 제출한 가답안 답안지를 지울 방법이 없음

회차 제목 "제63회 SQLD 가답안"에 앱이 꼬리말을 붙여 "가답안 가답안"으로 보이는 문제와 운영 안내 상자는 운영 데이터로 먼저 처리했다(제목 "SQLD 제63회", notice 비움).

## 재현 조건
- 5번: 운영 회차 1에서 0점 제출 > 결과 화면. 회차 제출 20건 중 17건이 0점이고 그중 15건이 빈 답안이던 상태.
- 4번: 다크 모드 > 내 가채점 > 결과 공유.
- 2번: 응답 1~2명인 갈림 문항.

## 조사 기록
- 2026-11-16: 이슈 본문은 5번을 "동점 처리 오류"로 보았으나, 순위 계산(나보다 높은 회원 수 + 1, [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]])은 맞았다. 운영 데이터상 0점 17건 중 15건이 한 문항도 고르지 않은 빈 답안이라, 이것이 응시자 수(분모)를 부풀린 것이 원인(커밋 c997c097 메시지).
- 2026-11-16: 4번은 [[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]가 "앱 다크 모드는 앱 배경"으로 정해 둔 그대로 구현된 동작이었다. 이슈는 흰 바탕 고정을 요구 > 결정을 [[DEC-0332-exam-answer-share-image-always-light]]로 대체.
- 2026-11-16: PR #1127(c997c097) main 머지 > 릴리스 PR #1130으로 서버·AI·웹·Android·iOS(심사 제출) 배포 성공. 소개 사이트 f658145b 시놀로지 배포·운영 확인.
- 2026-11-16: 배포 후 새 관리자 API로 테스트 답안지 2건(앱 검수 1, 웹 실측 1) 삭제 > 참여자 0.

## 근본 원인
모의고사 순위 재료 쿼리가 제출 상태·총점만 보고 응시를 셌기 때문에, 한 문항도 고르지 않은 빈 답안(시간 종료·바로 제출)이 0점 응시자로 분포에 들어갔다. 0점 동점이 많아질수록 "나보다 높은 회원 수 + 1" 순위가 0점에게 유리하게 나왔다. 나머지 6건은 실기 검수에서 드러난 표시·갱신 결함(제출 뒤 provider 무효화 누락, 최소 응답 수 기준 부재, 경고 상자 사용, 공유 카드가 앱 테마를 따름, 관리자 삭제 기능 부재).
