---
type: decision
id: DEC-0210
created: 2026-10-29
reviewed: null
topics: [design-system, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]", "[[DEC-0205-pro-benefits-single-source]]", "[[DEC-0211-benefit-colors-per-benefit]]"]
---

# DEC-0210: 이용권 혜택 아이콘은 앱에서 같은 기능에 이미 쓰는 아이콘으로 통일한다

## 문제 정의 (Context)
혜택 목록 원본 `pro_benefits.dart`([[DEC-0205-pro-benefits-single-source]])의 아이콘을 PR #752에서 다시 정했다.

## 결정 (Decision)
같은 기능을 앱 다른 화면에서 나타내는 아이콘을 그대로 쓴다.
- 랜덤 풀기: 셔플 (리포트)
- SQL 실행: 재생
- AI 해설: 반짝임
- 실전 모드(풀이 모드): 번개
- 출제 경향(최신 경향): 불꽃
- 통계: 육각형(8각 차트)

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음

**부정**
- 논의 기록 없음

## 영향 범위 (Scope)
앱 `widgets/pro/pro_benefits.dart` — 탑승권 아이콘, 구매 시트 혜택 줄, 정보 시트가 모두 읽는다.

## 출처 (References)
- PR #752 본문 (2026-10-29 07:30 main 머지), GitHub #749 리포트 댓글 6490566222 「변경 사항 1·2」「리뷰 반영」
- 사용자 정리 (2026-10-29 대화, "#752에서 정한 것")
- [[ISS-0428-app-profile-tab-redesign-report]]
