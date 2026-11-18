---
type: decision
id: DEC-0347
created: 2026-11-18
reviewed: null
topics: [home, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0544-callout-no-left-bar-roadmap-home-entry]]", "[[ISS-0544-callout-no-left-bar-roadmap-home-entry-report]]", "[[DEC-0331-study-guide-four-stages-progress-counts-study]]"]
---

# DEC-0347: 학습 가이드는 "합격 로드맵"으로 부르고 입구는 홈 한 곳(부제에 지금 단계)만 두며, 홈의 랜덤 풀기·모의고사·로드맵은 「더 풀기」 구간 하나로 묶는다

GitHub #1158. [[DEC-0331-study-guide-four-stages-progress-counts-study]] 의 「입구: 홈·문제 탭·프로필」 부분을 이 결정이 대신한다. DEC-0331 의 단계 순서·진행 계산은 그대로 유효(조건부, 2026-11-18 대화에서 사용자 승인).

## 문제 정의 (Context)
입구가 4곳이고 문제 탭에서는 프로 사용자에게 같은 행이 두 번 나왔다. "합격까지 이 순서로 공부해요" 문구로는 기능을 알 수 없었다. 홈에는 행 하나짜리 구간 3개가 제목 유무가 제각각이었다.

## 결정 (Decision)
- 이름 "합격 로드맵", 입구는 홈 「더 풀기」 구간 한 행. 부제 `지금 N단계 …` / `모든 단계를 마쳤어요` / 로딩·실패 `합격까지 4단계로 안내해요`.
- 문제 탭·프로필 입구 제거.
- 홈 「더 풀기」: 랜덤 풀기(결제 켜짐, 다음에 할 일 카드가 맡으면 숨김) > SQLD 모의고사 > 합격 로드맵, 구분선.
- 행 오른쪽 진행 표시는 두지 않음(목록 행 오른쪽 상태 글자 금지 규칙).

## 검토한 대안 (Alternatives)
- 입구 유지 + 문구만 개선: 논의 기록 없음(사용자가 추천안 전체 승인).

## 결과 (Consequences)
**긍정**
- 홈 입구 모양이 하나로 맞고, 행만 봐도 지금 할 단계가 보인다.

**부정**
- 문제 탭·프로필에서 바로 들어가는 길이 없어졌다.

## 영향 범위 (Scope)
앱 `widgets/study_guide/study_guide_entry_row.dart`, `pages/home/home_page.dart`, `pages/questions/topic_list_page.dart`, `widgets/profile/profile_bookmarks_section.dart`, `core/utils/study_guide_progress.dart`.

## 출처 (References)
- GitHub #1158 이슈 본문, 완료 보고서 댓글
