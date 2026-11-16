---
type: issue
id: ISS-0539
created: 2026-11-16
topics: [progress-stats, practice, design-system]
symptoms: ["1과목 정답률 57%, 과락 위험이 커요", "AI 분석 머리 문장과 예상 점수 불일치", "1과목 6/10 안전인데 과락 위험", "AiAnalysisPlanner.toHeadlineBody", "점수 올리기 좋은 영역 미표시", "scoreGainTopics 빈 목록", "AI 분석 캐시 배포 전 생성", "toStatsRefreshBucket", "가채점 계정 바꿔도 이전 답", "exam_answer_client_token", "exam_answer_draft_", "가답안 응답 0명 0% 막대", "메모 펜 버튼 보기 겹침", "문제 머리 별점 칩 3개", "AI 분석 회색 상자 과락 위험 칩 약점 알약"]
root_cause: "AI 분석 한 줄 요약은 1과목 토픽 정답률로, 예상 점수는 과목 예상 정답 수(SqldScoreMargin)로 과락을 따로 판정했고, 통계 분석 캐시 키에 응답 형식 버전이 없어 scoreGainTopics 배포 전 캐시가 재사용됐으며, 가채점 임시 답안·답안지 토큰이 계정 구분 없는 기기 키였다"
status: resolved
resolution: "[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]"
related: ["[[DEC-0334-ai-analysis-fail-risk-single-source]]", "[[DEC-0335-stats-analysis-cache-key-schema-version]]", "[[DEC-0336-exam-answer-draft-token-per-owner]]", "[[DEC-0260-exam-forecast-score-thresholds]]", "[[DEC-0322-score-gain-topics-exam-weighted]]", "[[DEC-0323-pass-fail-margin-count-single-source]]", "[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]", "[[DEC-0332-exam-answer-share-image-always-light]]", "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]", "[[ISS-0525-pass-fail-margin-score-gain-topics]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[ISS-0473-solving-memo-pen-toggle]]"]
source: "_sources/issues/ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner.md"
---

# ISS-0539: 프로 계정 재검수 결함 5건 (AI 분석 과락 판정 불일치, 가채점 계정 분리, 점수 올리기 영역 미표시, 화면 정리)

GitHub #1136. 원본 URL: https://github.com/Twin-Fang/passQL/issues/1136

## 증상
[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]에서 남긴 프로 계정 재검수(2026-11-16, iOS 시뮬레이터)에서 나온 결함 5건.
1. (서버) AI 분석 머리 문장 "1과목 정답률 57%, 과락 위험이 커요" 바로 아래 예상 점수는 1과목 6/10 안전, 2과목 과락 위험으로 서로 어긋남
2. (앱) 가채점 OMR 임시 답안과 답안지 토큰(clientToken)이 기기 단위라 로그아웃 후 다른 계정으로 로그인해도 이전 계정 답이 보임
3. (서버) 점수 올리기 좋은 영역(`scoreGainTopics`)이 프로 계정 화면에 표시되지 않음
4. (앱) 가답안 펼침에서 응답 0명인데 "0% | 0" 막대 4개
5. (앱) AI 분석 회색 상자 예상 점수 카드·"과락 위험" 칩·빨간 "약점" 알약 반복·쌓인 버튼 2개, 문제 풀이 머리 별점·칩 3개, 메모 펜 버튼이 보기 C 위에 겹침

## 재현 조건
- 1·3번: 프로 계정 > 프로필 > AI 분석 (1과목 예상 정답이 과락선 이상, 2과목은 미만인 계정).
- 2번: 시험 > SQLD 63회 가답안과 가채점 > 답 입력 > 로그아웃 > 다른 계정 로그인.
- 4번: 가답안 탭 > 응답 0명 문항 펼침.

## 조사 기록
- 2026-11-16: 1번은 두 판정의 기준이 달랐다. 한 줄 요약(`AiAnalysisPlanner.toHeadlineBody`)은 첫 집중 토픽이 1과목이면 토픽 정답률만 보고 "과락 위험"이라 말했고, 예상 점수는 `ExamForecastCalculator` 가 과목 예상 정답 수를 `SqldScoreMargin`(과락선 1과목 4, 2과목 16)과 비교했다([[DEC-0323-pass-fail-margin-count-single-source]]).
- 2026-11-16: 3번은 계산기 문제가 아니라 캐시였다. 통계 분석 캐시 키가 날짜 + 풀이 수 10문제 구간(`2026-11-16:guide-N`)뿐이라 #1111 배포 전에 만든 캐시가 같은 키로 남아 `scoreGainTopics` 가 빈 목록으로 읽혔다. [[DEC-0322-score-gain-topics-exam-weighted]] 「결과·부정」에 예상돼 있던 현상.
- 2026-11-16: 2번은 #1075 구현([[ISS-0520-sqld-round-answer-key-omr-grading]])이 "로그인 여부와 무관하게 기기 토큰 하나"로 만든 결과(코드 주석, 볼트 결정 없음).
- 2026-11-16: PR #1137(커밋 cf096426) main 머지 > 릴리스 PR #1138로 서버·AI·웹 배포 성공. Android·iOS 스토어 심사 제출 워크플로는 진행 중(보고서 기록). 검수는 사용자 본인 프로 계정(카카오 로그인, 사용자 2단계 승인)으로 진행, 문제 제출 1회 남음.

## 근본 원인
과락 판정 원본이 두 벌(토픽 정답률 <-> 과목 예상 정답 수)이었고, 통계 분석 캐시 키에 응답 형식 버전이 없어 응답 모양이 바뀐 배포 뒤에도 옛 캐시가 쓰였으며, 가채점 기기 저장 키에 계정(주인) 구분이 없었다. 4·5번은 표시 결함과 앱 디자인 원칙([[DEC-0116-app-apple-hig-design-system]]) 위반.

## 결정 충돌 메모 (W4, 사용자 확인 필요)
5번의 문제 풀이 머리 정리(별점·칩 3개 > 회색 메타 한 줄 `난이도 N | 개념 문제 | 최신 경향`)는 [[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]](active)의 "난이도 별 `PassqlDifficultyStars` 를 풀이 머리·홈 추천·프로필 3곳 통일" 중 풀이 머리 부분과 다르다. 이슈 본문은 근거로 DEC-0116·DEC-0332/DEC-0321만 들었고 DEC-0303은 언급하지 않았다. 대체 여부는 사용자 결정 전이라 DEC-0303은 바꾸지 않았다.
