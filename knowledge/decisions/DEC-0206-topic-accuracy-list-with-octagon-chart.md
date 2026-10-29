---
type: decision
id: DEC-0206
created: 2026-10-29
reviewed: null
topics: [progress-stats, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]"]
---

# DEC-0206: 앱 영역별 정답률은 목록을 기본으로 두고 같은 자리에서 8각 차트로 바꿔 본다 (레이더·막대 두 장 통합, `fl_chart` 제거)

## 문제 정의 (Context)
앱 프로필 탭에 레이더 차트와 막대 차트가 두 장으로 나뉘어 있었다. 이슈 본문은 둘을 목록 하나로 합치라고 했고(GitHub #749), 리포트는 "약한 곳을 한눈에 비교하려는 요청"이라고 적었다.

## 결정 (Decision)
- 기본 보기는 목록: 토픽 아이콘 타일 + 영역 이름 + `N문제 풀었어요` + 정답률. 정렬 토글 「정답률 낮은 순 ↔ 많이 푼 순」, 처음 4줄 + 펼치기, 안 푼 영역은 맨 아래, 누르면 그 영역 문제로.
- 제목 줄 오른쪽 아이콘 한 쌍으로 같은 자리에서 8각 차트로 바꿔 본다. 꼭짓점은 토픽 순서(정렬과 무관하게 고정), 내 정답률 면, 60% 기준 점선. 차트일 때 정렬 숨김, 영역 3개 미만·무료면 아이콘 없음. 고른 보기는 화면에 있는 동안만 유지.
- 약한 영역 기준 60%(`weakAccuracyThreshold`) 미만만 빨강. 높은 정답률은 색을 칠하지 않는다.
- 8각 차트는 라이브러리 없이 직접 그리고, 레이더에서만 쓰던 `fl_chart` 의존성은 `pubspec.yaml`에서 뺀다.

## 검토한 대안 (Alternatives)
- 막대 보기: 시안에서 비교한 뒤 뺐다 — "막대는 목록과 겹치고".
- 꼭짓점 타일: 시안에서 비교한 뒤 뺐다 — "꼭짓점 타일은 휴대폰 폭에서 너무 작아짐".
- 높은 정답률에도 색 칠하기: 하지 않음 — "나머지가 무채색이어야 빨강이 튀고, 앱 강조색(보라)과 겹치지 않게".
- `fl_chart` 유지: 이슈 본문이 "레이더에서만 쓰던 `fl_chart` 의존성도 뺀다"고 적었다. 그 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 레이더·막대 두 장이 구간 하나로 줄었다 (이슈 기대: 카드 10장 → 구간 4개).
- 의존성 하나(`fl_chart`) 제거.

**부정 / 조건**
- 긴 이름("DDL / DML / TCL")은 차트에서 두 줄로 꺾인다 (리포트).
- 60% 기준이 목록 빨강, 차트 꼭짓점·이름 빨강, 차트 점선 공용이라 한 값을 바꾸면 모두 바뀐다.

## 영향 범위 (Scope)
앱 `widgets/profile/topic_accuracy_section.dart`, `topic_accuracy_rows.dart`, `topic_accuracy_radar.dart`(신규), 삭제된 `radar_chart_section`·`bar_chart_section`, `pubspec.yaml`, `app/CLAUDE.md` 기술 스택.

## 출처 (References)
- GitHub #749 이슈 본문 「4. 영역별 정답률」「추가 요청 사항」(2026-10-28), 리포트 댓글 「주요 구현 내용 5」(2026-10-29)
- [[ISS-0428-app-profile-tab-redesign-report]]
