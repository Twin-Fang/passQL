---
type: completion-report
id: ISS-0539
created: 2026-11-16
topics: [progress-stats, practice, design-system]
status: resolved
resolves: "[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]"
related: ["[[DEC-0334-ai-analysis-fail-risk-single-source]]", "[[DEC-0335-stats-analysis-cache-key-schema-version]]", "[[DEC-0336-exam-answer-draft-token-per-owner]]", "[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1136#issuecomment-6909470371"
---

# ISS-0539 완료 리포트: 과락 판정 단일 원본, 분석 캐시 형식 버전 v3, 가채점 주인별 저장, AI 분석·풀이 머리 정리 (#1136)

## 해결 방법
PR #1137(커밋 cf096426), 릴리스 PR #1138로 서버·AI·웹 배포 성공. Android·iOS 스토어 심사 제출은 진행 중(결과는 이슈 후속 댓글).
- **과락 판정(서버):** `AiAnalysisPlanner.toHeadlineBody` 가 `ExamForecastCalculator.failRiskSubjectsOf`(> `SqldScoreMargin`) 결과로 과락 과목을 말함 — "2과목 예상 14/40, 과락 위험이 커요" / "두 과목 모두 과락 위험이 커요". `ExamForecastCalculator` 에 `failRiskSubjectsOf`·`expectedCorrectCountOf` 공개. 결정 [[DEC-0334-ai-analysis-fail-risk-single-source]].
- **캐시(서버):** `AiCommentService.STATS_ANALYSIS_SCHEMA_VERSION = "v3"`, 키 `2026-11-16:guide-v3-2`. 결정 [[DEC-0335-stats-analysis-cache-key-schema-version]].
- **가채점(앱):** `ExamAnswerDeviceStore` 토큰·임시 답안 키를 주인 키(`member_{uuid}` / `guest`)로, `StorageKeys.examAnswerOwnerDraftPrefix`·`examAnswerClientTokenPrefix`. Notifier 가 `currentMemberUuidProvider` 를 구독해 계정이 바뀌면 다시 만들고, 불러오는 사이 계정이 바뀌면 결과를 버림. 결정 [[DEC-0336-exam-answer-draft-token-per-owner]].
- **화면(앱):** 응답 0명 펼침 "아직 응답이 없어요" 한 줄, AI 분석 회색 상자·칩·알약 > 판정 의미색 글자, 버튼 2개 > 목록 행 + 채운 버튼 하나, 문제 머리 > 회색 메타 한 줄, 메모 펜은 내용 끝 펜 자리 여백이 보일 때만(`passql_memo_scope.dart`).

## 근본 원인 (확정)
과락 판정 원본 두 벌(토픽 정답률 <-> 과목 예상 정답 수), 통계 분석 캐시 키에 형식 버전 없음, 가채점 기기 저장 키에 계정 구분 없음.

## 재발 방지
- `AiAnalysisPlannerTest` 에 과락 문장이 예상 점수 판정을 따르는 경우 고정, 앱 `exam_answer_device_store_test`(주인별 키)·`passql_memo_scope_test`(펜 표시 조건).
- 통계 분석 응답 필드·판정 규칙을 바꿀 때 `STATS_ANALYSIS_SCHEMA_VERSION` 을 올린다(보고서 주의 사항).

## 교훈
- 같은 화면 두 문구가 같은 사실(과락)을 말하면 판정 함수 하나를 함께 호출하게 한다 — 따로 계산하면 기준이 어긋난다.
- 응답 모양이 바뀌는 배포는 캐시 키도 함께 바꾼다. 날짜·풀이 수 같은 데이터 구간만으로는 형식 변경을 구분하지 못한다.
- 남은 일: 스토어 심사 제출 결과 후속 확인, 검수용 문제 제출 1회. 문제 풀이 머리 별점 제거가 [[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]] 와 다른 점은 사용자 확인 대기.
- 2026-11-16 해소: 풀이 머리 별점 제거와 DEC-0303 차이는 사용자가 "별 대신 글자 3단계(쉬움 1~2, 보통 3, 어려움 4~5)" 추천안을 승인해 정리됨. 풀이 머리·홈 추천·프로필을 같은 회색 글자로 통일 — [[DEC-0342-app-difficulty-text-label-three-levels]] (#1145, DEC-0303 대체).
