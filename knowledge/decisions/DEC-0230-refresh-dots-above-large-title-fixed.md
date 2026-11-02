---
type: decision
id: DEC-0230
created: 2026-10-31
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0436-app-pull-to-refresh-glow-indicator]]", "[[DEC-0229-refresh-wave-dots-fullscreen-glow-component]]", "[[DEC-0231-refresh-glow-on-release-wave-while-holding]]"]
---

# DEC-0230: 새로고침 점은 큰 제목 위에 두고, 아무리 당겨도 화면에 고정한다

## 문제 정의 (Context)
큰 제목 탭 화면은 새로고침 표시를 큰 제목 바 아래에 두고 있었다. 그래서 당기면 큰 제목과 내용 사이가 벌어졌다 (사용자 "문제 하단이 댕겨진다", GitHub #772). 또 점이 띠 아래쪽에 붙어 있어 당긴 만큼 내용을 따라 내려갔다.

## 결정 (Decision)
- `PassqlLargeTitleScrollView`는 새로고침 sliver를 큰 제목 바(`CupertinoSliverNavigationBar`) 앞에 둔다.
  - 점은 상단 바(상태 표시줄 + 바 높이)만큼 내려 그려(`indicatorOffset`) 큰 제목 바로 위에 온다.
  - 펼친 큰 제목 바는 배경이 투명해서 점이 보인다.
- 홈(`PassqlBrandBarScrollView`)은 고정 상단 바 아래 그대로 둔다.
- 점과 아래 내용 사이는 `PassqlSpacing.xl`만큼 띄운다.
- 점은 띠 위쪽(화면에 고정된 쪽)부터 새로고침 띠 높이만큼 칸을 잡고, 그 칸 아래쪽에 놓는다.
  - 당긴 거리와 상관없이 같은 자리에 있다.
  - 새로고침 중 자리와 같아서 손을 떼도 튀지 않는다.

## 검토한 대안 (Alternatives)
- 큰 제목 아래 (원래 자리): 당길 때 제목과 내용 사이가 벌어져 뺐다. "지금 자리 vs 통일되게 제목 위"를 물었고, 사용자가 제목 위를 골랐다.
- 제목 위로 옮기고 띠 기준 그대로 두기: 점이 상태 표시줄 쪽으로 너무 높이 떠서(사용자 "너무 위에 표시됨"), 상단 바만큼 내렸다.
- 간격 `md`: 사용자가 더 넓히길 원해 `xl`로 늘렸다.
- 띠 아래쪽 정렬 (당긴 만큼 내용을 따라 내려감): 사용자가 "아무리 많이 댕겨도 위치 고정되어 있어야지"라고 해서 고정으로 바꿨다.

## 결과 (Consequences)
**긍정**
- 당겨도 큰 제목과 내용 사이 간격이 그대로다.
- 점 위치가 당김과 새로고침 내내 같아서 예측하기 쉽다.

**부정**
- 펼친 큰 제목 바의 배경이 투명해야 점이 보인다. 바 배경이 바뀌면 점이 가려질 수 있다.
- 당기기 시작할 때는 점이 띠 밖(내용 쪽)에 걸쳐 그려진다. 그래서 당긴 거리에 따라 투명도로 서서히 나타나게 했다.

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_large_title_scroll_view.dart`(새로고침 sliver 순서, `indicatorOffset`), `passql_refresh_control.dart`(점 배치).

## 출처 (References)
- GitHub #772 구현 세션의 사용자 피드백
- [[ISS-0436-app-pull-to-refresh-glow-indicator]]
