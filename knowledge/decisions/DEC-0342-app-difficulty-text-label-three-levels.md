---
type: decision
id: DEC-0342
created: 2026-11-16
reviewed: null
topics: [design-system, practice, progress-stats]
status: superseded
supersedes: DEC-0303
superseded_by: DEC-0343
related: ["[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]", "[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[DEC-0332-exam-answer-share-image-always-light]]", "[[DEC-0274-stats-radar-above-list-study-pattern-free]]"]
---

# DEC-0342: 앱 난이도는 별 대신 글자 3단계(쉬움 1~2, 보통 3, 어려움 4~5)로 풀이 머리·홈 추천·프로필에 같은 회색 글자로 보여 준다 (DEC-0303의 카운트업·PK FK 배지·과락 기준 칸은 그대로)

GitHub #1145.

## 문제 정의 (Context)
[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]는 풀이 머리·홈 추천·프로필 세 곳의 난이도를 별 부품 `PassqlDifficultyStars`로 통일했다. #1136(PR #1137)에서 풀이 머리만 "난이도 N" 회색 메타 글자로 바뀌어 세 곳이 불일치했고, 이 차이는 사용자 확인 대기로 남아 있었다([[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]).

## 결정 (Decision)
DEC-0303의 내용을 이어받고 난이도 표시 규칙 하나만 바꾼다.
- **변경 — 난이도:** 별 대신 글자 3단계. 문항 난이도 1~5 > `쉬움`(1~2) · `보통`(3) · `어려움`(4~5), 값이 없거나 범위 밖이면 표시하지 않는다. 변환은 앱 `core/utils/question_difficulty.dart` 의 `toDifficultyLabel`(단계 enum `QuestionDifficultyLevel`) 한 곳.
  - 풀이 머리: 회색 메타 한 줄 `보통 | 개념 문제 | 최신 경향`.
  - 홈 추천: 문제 미리보기 아래 같은 회색 글자.
  - 프로필 난이도별 정답률: 1~5 기록을 3단계 행(쉬움·보통·어려움)으로 묶어 표시(푼 문제 수 합, 정답률은 푼 수 가중 평균, `toDifficultyLevelStats`).
  - 색은 회색 보조 글자(secondaryLabel)만. 칩·그라데이션·장식 색 없음([[DEC-0116-app-apple-hig-design-system]], [[DEC-0332-exam-answer-share-image-always-light]] 원칙).
  - 별 부품 `PassqlDifficultyStars` 제거. 화면 코드의 `"난이도 $..."` 숫자 표기·`★☆` 글자는 디자인 시스템 규칙 테스트로 금지.
  - 모의고사 회차 평균 난이도(#1084)도 같은 단계 이름을 쓴다(평균 경계 2.5·3.5는 그대로).
- **유지 (DEC-0303 그대로):** 카운트업 `PassqlCountUp`(모의고사 총점·크레딧 잔액), 표 머리 PK·FK 색 구분 배지(반경 토큰 `keyBadge`), 모의고사 과락 안내는 `과목별 과락 기준` 카드 + 과목 칸.

## 검토한 대안 (Alternatives)
- 별 부품 유지(DEC-0303 원안): 풀이 머리를 다시 별로 돌려야 하고, #1136에서 정리한 회색 메타 한 줄과 맞지 않아 버림. 그 밖의 대안 논의 기록 없음.
- "난이도 N" 숫자 글자: 논의 기록 없음(사용자가 3단계 글자 추천안을 승인).

## 결과 (Consequences)
**긍정**
- 세 곳이 같은 낱말·같은 회색 글자로 맞는다. 모의고사 회차 행의 난이도 낱말과도 같다.

**부정**
- 프로필 난이도별 정답률이 5행에서 3행으로 줄어 1과 2, 4와 5의 차이는 보이지 않는다.
- 웹(client `StarRating`: 풀이 머리·홈 추천·통계 난이도별 정답률)과 관리자 화면은 여전히 별이다. DEC-0303의 "웹·관리자 별과 같은 뜻"은 이 결정으로 깨진다. 웹 정렬은 별도 이슈.

## 영향 범위 (Scope)
`app/lib/core/utils/question_difficulty.dart`, `app/lib/data/models/progress/difficulty_level_stat.dart`, `app/lib/presentation/widgets/question/question_sections.dart`, `app/lib/presentation/widgets/home/recommendations_section.dart`, `app/lib/presentation/widgets/profile/difficulty_accuracy_section.dart`, 디자인 시스템 부품 목록(`PassqlDifficultyStars` 제거), `app/test/architecture/design_system_rules_test.dart`.

## 출처 (References)
- GitHub #1145 이슈 본문, 사용자 추천안 승인(난이도 1~5 > 쉬움 1~2, 보통 3, 어려움 4~5)
- #1136 / PR #1137, [[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]
