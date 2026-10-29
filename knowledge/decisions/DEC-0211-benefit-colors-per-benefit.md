---
type: decision
id: DEC-0211
created: 2026-10-29
reviewed: null
topics: [design-system, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]", "[[DEC-0210-benefit-icons-reuse-app-icons]]"]
---

# DEC-0211: 혜택 아이콘 색은 혜택마다 다른 색으로 두고, 출제 경향 불꽃만 문제 탭 불꽃 색(`warning`)을 쓴다

## 문제 정의 (Context)
PR #752에서 혜택 아이콘을 앱 아이콘으로 통일하면서([[DEC-0210-benefit-icons-reuse-app-icons]]) 색도 다시 정했다.

## 결정 (Decision)
- 혜택마다 다른 색조를 유지한다.
- 출제 경향 불꽃만 문제 탭 불꽃과 같은 `warning`.

## 검토한 대안 (Alternatives)
- 색을 전부 앱 강조색(보라)으로 맞추기: 버렸다. 리포트: "보라 탑승권 위에서 보라 타일 4개가 묻혀 되돌림". (원본에 없음, 사용자 구두 2026-10-29) 다채롭지 않아서.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음 (버린 안의 문제를 피한 것 외에는 적혀 있지 않다)

**부정**
- 논의 기록 없음

## 영향 범위 (Scope)
앱 `widgets/pro/pro_benefits.dart`, 탑승권 혜택 아이콘 줄, 구매·정보 시트 혜택 줄.

## 출처 (References)
- PR #752 본문 (2026-10-29 07:30 main 머지), GitHub #749 리포트 댓글 6490566222 「변경 사항 1·2」「리뷰 반영」
- (원본에 없음) 사용자 구두 정리 (2026-10-29 대화, "#752에서 정한 것") — 공개 원본으로 확인할 수 없다
- [[ISS-0428-app-profile-tab-redesign-report]]
