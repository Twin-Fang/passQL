---
type: completion-report
id: ISS-0538
created: 2026-11-16
topics: [practice, progress-stats, design-system, admin]
status: resolved
resolves: "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]"
related: ["[[DEC-0332-exam-answer-share-image-always-light]]", "[[DEC-0333-mock-exam-ranking-excludes-empty-attempts]]", "[[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]", "[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1126#issuecomment-6907744218"
---

# ISS-0538 완료 리포트: 빈 답안 순위 제외, 공유 이미지 흰 바탕 고정, 합의율 최소 응답 수, 관리자 답안지 삭제 (#1126)

## 해결 방법
PR #1127(커밋 c997c097), 릴리스 PR #1130으로 서버·AI·웹·Android·iOS(심사 제출) 배포. 소개 사이트는 gh-pages 커밋 f658145b.
- **모의고사 순위(서버):** `MockExamAttemptRepository.findSubmittedScoresByRoundInSubmitOrder`에 "선택한 답이 하나라도 있는 응시" EXISTS 조건 > 빈 답안을 분포에서 제외. `MockExamAttemptService`가 내 응시의 답 여부(`hasAnsweredAnyQuestion`)를 넘기고, `MockExamRankingCalculator.rank`는 빈 답안이면 `null`. null 조건 2개: 내 응시가 빈 답안, 응시자 10명 미만. 결정 [[DEC-0333-mock-exam-ranking-excludes-empty-attempts]].
- **관리자 답안지 관리:** `ExamAnswerSheetAdminService`(신규) — 회차 답안지 최근 100장(제출 시각·경로·토큰 해시 앞 6자리·답 50자), `DELETE /admin/exam-answers/{roundUuid}/sheets/{sheetUuid}`(회차 소속 확인 > 삭제 > 감사 로그 > 커밋 뒤 공개 집계 캐시 비움).
- **참여 수 갱신(앱):** 가채점 제출 성공 시 `examAnswerRoundProvider`·`examAnswerHomeEntryProvider` 무효화.
- **합의율(앱·사이트):** 응답 5명 미만 문항은 `합의 N%` 대신 `응답 N명`. 기준은 앱 `ExamAnswerDisplayRule.minimumAgreementVoteCount`, 사이트 `_src/site_answer_key_content.py`의 `MINIMUM_AGREEMENT_VOTE_COUNT`(같은 값 5, 정적 생성과 `exam-answer-table.js` 실시간 갱신이 공유).
- **메모:** 주황 경고 상자(`PassqlCallout`) > 회색 보조 글자 한 줄.
- **공유 이미지:** `ExamAnswerShareCard`를 `Theme(data: PassqlTheme.light)`로 감싸 다크 모드에서도 흰 바탕·라이트 로고. 결정 [[DEC-0332-exam-answer-share-image-always-light]](DEC-0321 대체).
- **제목 꼬리말:** `ExamAnswerDisplayRule.titleWithSuffix` — 제목에 이미 `가답안`·`가채점`이 있으면 붙이지 않음(홈 구간·회차 요약·공유 문구).
- **모의고사 결과 머리:** 큰 X 원·알약 칩 > 판정 색 글자 + 큰 점수 + 목록 행(정답, 풀이 시간, 응시자 중 순위).
- **운영 조치:** 회차 제목 "제63회 SQLD 가답안" > "SQLD 제63회", notice 비움. 배포 후 테스트 답안지 2건(앱 검수 1, 웹 실측 1) 삭제 > 참여자 0.

## 근본 원인 (확정)
순위 재료 쿼리가 빈 답안을 응시로 셌다. 운영 회차 1 제출 20건 중 17건 0점, 그중 15건이 빈 답안 > 0점이 "20명 중 4위, 상위 20%". 순위 공식(나보다 높은 회원 수 + 1) 자체는 맞았다.

## 재발 방지
- `MockExamRankingCalculatorTest`에 빈 답안이면 순위를 숨기는 경우 고정.
- 순위 쿼리를 바꿀 때 EXISTS 조건을 빼면 빈 답안 0점 무리가 다시 분모에 들어간다(보고서 주의 사항).
- 합의율 최소 응답 수는 앱·사이트 두 곳 사본이라 함께 고친다(앱 `ExamAnswerDisplayRule`, 사이트 `site_answer_key_content.py`).

## 교훈
- "동점 처리 오류"처럼 보이는 순위 이상은 공식보다 먼저 분모(누가 응시자로 세어지는가)를 운영 데이터로 확인한다.
- 남은 일: 무료 계정 실기 검수라 프로 전용 화면(점수 올리기 +N점, 최신 경향 신유형 문제)은 잠금까지만 확인 — 프로 계정 재검수 필요. 관리자 답안지 삭제는 복원 기능이 없다.
