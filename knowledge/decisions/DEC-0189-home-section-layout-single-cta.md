---
type: decision
id: DEC-0189
created: 2026-10-27
reviewed: null
topics: [home, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0413-app-home-ui-ux-redesign]]", "[[ISS-0413-app-home-ui-ux-redesign-report]]"]
---

# DEC-0189: 앱 홈은 카드 대신 좌우 끝까지 닿는 구간(면 + 회색 띠)으로 나누고, 채운 버튼은 「오늘의 세트 풀기」 하나만 둔다 (다른 탭은 카드 유지)

## 문제 정의 (Context)
홈 카드가 많고 위계가 안 보였다 (GitHub #701 리포트 결정 기록 1).

## 결정 (Decision)
- 홈은 구간(면 `card` 토큰 + 구간 사이 `md 16` 회색 띠 `background` 토큰) 방식. 문제·토론·프로필 탭은 카드 유지.
- 채운 버튼은 홈 전체에서 「오늘의 세트 풀기」 하나. 나머지는 목록 행 + `›`, 글자 링크.
- 구간 제목은 같은 틀(44pt 제목 줄, headline) 하나, 간격은 `PassqlSpacing` 토큰만.
- 광고는 학습 현황 아래 구간 하나(광고가 뜰 때만 면·띠 생성, 결정 기록 5).

## 검토한 대안 (Alternatives)
- 앱 전체를 구간으로 통일: 범위 과대로 버림(결정 기록 1).
- 광고를 학습 현황 구간 안 또는 출제 경향 앞에: 버림(결정 기록 5, 이유는 표에 따로 없음).
- 근거로 든 자료(리포트): 토스 TDS `Border height16`·`ListRow`, `app/.claude/rules/TOSS_UI_UX_DESIGN.md`(힉·밀러·폰 레스토프·피츠의 법칙), 토스 홈(카드) vs 토스 증권(구간)이 행·글자·색을 공유해 한 앱처럼 보인다는 기준.

## 결과 (Consequences)
**긍정**
- 화면 단위로 한 방식만 쓰고 행·제목·링크·색 토큰은 공유.

**부정**
- 탭 사이 모양 차이는 남는다(결정 기록 1).
- `PassqlListRow` 화살표 확대(14 → 18)가 홈 밖 목록 행에도 적용.

## 영향 범위 (Scope)
`app/lib/presentation/pages/home/home_page.dart`, `design/components/passql_section*.dart`, `passql_list_row.dart`, `widgets/ads/ad_inline_card.dart`, `test/architecture/ad_placement_rules_test.dart`, `app/CLAUDE.md`.

## 출처 (References)
- GitHub #701 확정 댓글 「레이아웃 원칙」, 리포트 「결정 기록」 1·5
- [[ISS-0413-app-home-ui-ux-redesign]]
