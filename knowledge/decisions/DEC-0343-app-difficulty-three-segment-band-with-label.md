---
type: decision
id: DEC-0343
created: 2026-11-17
reviewed: null
topics: [design-system, practice, progress-stats, home]
status: active
supersedes: DEC-0342
superseded_by: null
related: ["[[DEC-0342-app-difficulty-text-label-three-levels]]", "[[ISS-0541-app-difficulty-three-segment-band]]", "[[ISS-0541-app-difficulty-three-segment-band-report]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[DEC-0332-exam-answer-share-image-always-light]]"]
---

# DEC-0343: 앱 난이도는 가로 3칸 띠 + 글자(쉬움 1칸, 보통 2칸, 어려움 3칸)로 보여 주고, 홈 추천 행의 칩은 제목 위 회색 메타 한 줄로 합친다 (DEC-0342의 3단계 구간·프로필 3행 묶기는 그대로)

GitHub #1147.

## 문제 정의 (Context)
[[DEC-0342-app-difficulty-text-label-three-levels]]로 난이도를 별 대신 회색 글자(쉬움, 보통, 어려움)로 바꿨지만, 글자만으로는 단계가 한눈에 들어오지 않았다. 난이도 표시 시안 v3에서 6가지 방식(상·중·하, 실제 정답률, 사람 수, 정답률 + 막대, 가로 3칸 띠, 예상 풀이 시간)을 비교했다.

## 결정 (Decision)
DEC-0342의 내용을 이어받고 표시 모양과 홈 추천 행 배치를 바꾼다.
- **변경 — 난이도 모양:** 가로 3칸 띠 + 글자. 쉬움 1칸, 보통 2칸, 어려움 3칸을 채운다. 칸은 납작한 둥근 막대(10x4, 간격 2), 채운 칸 secondaryLabel, 빈 칸 tertiaryLabel, 글자 높이 가운데 정렬. 이미지 에셋 없이 코드로 그리는 공통 부품 `PassqlDifficultyIndicator` 하나만 쓰고, 채운 칸 수는 `QuestionDifficultyLevel.difficultyStepNumber`(원본 구간 `toQuestionDifficultyLevel`)에서 나온다.
  - 풀이 머리: `━━─ 보통 | 개념 문제 | 최신 경향`.
  - 홈 추천 행: 보라 알약 칩(토픽, 최신 경향)을 없애고 제목 위 회색 메타 한 줄 `SQL 기본 | 최신 경향 | ━━─ 어려움`. 제목 아래 난이도 줄은 없앤다.
  - 프로필 난이도별 정답률: 3행 라벨 앞에 띠.
  - 화면 코드의 난이도 띠·글자 직접 그리기(`toDifficultyLabel(`, `.difficultyStepNumber/Count`)는 디자인 시스템 규칙 테스트로 금지.
- **유지 (DEC-0342 그대로):** 1~5 > 3단계 구간(쉬움 1~2, 보통 3, 어려움 4~5), 값이 없거나 범위 밖이면 표시 안 함, 프로필 1~5 기록을 3행으로 묶기, 별 부품 없음과 `"난이도 $..."`·`★☆` 금지, 모의고사 회차 평균 난이도는 글자만(평균 경계 2.5·3.5), DEC-0303에서 이어받은 카운트업·PK FK 배지·과락 기준 칸, 칩·장식 색 없는 회색 원칙.

## 검토한 대안 (Alternatives)
- 실제 정답률(B, 시안 추천안)과 정답률 + 얇은 막대(D): 사용자가 적어 대부분 문항이 표본 부족이라 버림.
- 세로 막대: 가로 띠가 실제 크기에서 글자 높이와 겹치지 않아 더 또렷해서 버림.
- 상·중·하(A), 사람 수 문장(C), 예상 풀이 시간(F): 고르지 않은 이유의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 띠 모양과 글자가 함께 단계를 전해 색에 기대지 않고도 구분된다.
- 홈 추천 행이 풀이 머리와 같은 회색 메타 한 줄이 되어 칩 장식이 사라진다.

**부정**
- 빈 칸 tertiaryLabel 은 대비가 낮아 단독으로는 읽기 어렵다(옆 글자가 의미를 전달).
- 홈 추천의 보라 칩이 사라지며 `PassqlLatestTrendBadge` 와 배지 종류 `latestTrend` 를 제거했다. 다시 칩이 필요하면 새로 만들어야 한다.
- 웹·관리자 화면은 여전히 별이다(DEC-0342의 부정 결과 그대로).

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_difficulty_indicator.dart`, `app/lib/core/utils/question_difficulty.dart`, `app/lib/presentation/design/tokens/passql_size.dart`, `app/lib/presentation/widgets/question/question_sections.dart`, `app/lib/presentation/widgets/home/recommendations_section.dart`, `app/lib/presentation/widgets/profile/difficulty_accuracy_section.dart`, `app/lib/presentation/design/components/passql_badge.dart`, `app/test/architecture/design_system_rules_test.dart`.

## 출처 (References)
- GitHub #1147 이슈 본문, 난이도 표시 시안 v3 사용자 선택(E. 가로 3칸 띠, 홈 추천 칩은 회색 메타 한 줄로)
- PR #1148, 완료 리포트 [[ISS-0541-app-difficulty-three-segment-band-report]]
