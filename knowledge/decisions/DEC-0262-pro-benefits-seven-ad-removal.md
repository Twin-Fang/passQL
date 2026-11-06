---
type: decision
id: DEC-0262
created: 2026-11-07
reviewed: null
topics: [billing, design-system, ads]
status: active
supersedes: DEC-0205
superseded_by: null
related: ["[[ISS-0461-plan-aligned-options-new-choices-mode]]", "[[ISS-0461-plan-aligned-options-new-choices-mode-report]]", "[[DEC-0205-pro-benefits-single-source]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0210-benefit-icons-reuse-app-icons]]", "[[DEC-0211-benefit-colors-per-benefit]]", "[[DEC-0261-real-mode-renamed-new-choices]]"]
---

# DEC-0262: 앱 이용권 혜택 목록은 `pro_benefits.dart` 한 곳을 원본으로 두고 실제 잠금·해제가 있는 기능만 보이며, 혜택은 광고 제거를 더한 7개다

## 문제 정의 (Context)
프로를 사면 광고가 사라지는데 혜택 목록에 광고 제거가 없었다 (GitHub #863, [[ISS-0461-plan-aligned-options-new-choices-mode]]). 이슈 본문은 "실제 잠금·해제가 있는 기능만 보인다는 DEC-0205 유지"를 조건으로 적었다. 혜택 6개를 정한 [[DEC-0205-pro-benefits-single-source]] 를 대체한다.

## 결정 (Decision)
- 원본 하나: `widgets/pro/pro_benefits.dart`. 탑승권 아이콘, 구매 시트 혜택 줄, 정보 시트가 모두 이것을 읽는다 (DEC-0205 에서 유지).
- 보이는 혜택은 앱에 실제 잠금·해제가 있는 기능만 (DEC-0205 에서 유지).
- 혜택 7개 (순서 = 탑승권 아이콘 순서·`focusedBenefitIndex` 기준, 새 혜택은 끝에 붙임): 문제 풀이, SQL 직접 실행, 해설, 새 보기·토픽, 출제 경향, 통계, 광고 제거.
- "실전 모드·토픽" 라벨은 "새 보기·토픽"으로 바뀜 ([[DEC-0261-real-mode-renamed-new-choices]]).
- 광고 제거: 결제로 산 프로는 실제로 광고가 꺼진다 (`adsEnabledProvider` 판정). 아이콘 `eye_slash`, 색조 teal.
- 무엇을 PRO 혜택으로 둘지의 경계는 [[DEC-0004-free-pro-feature-boundary]].

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 결제 혜택에 실제 체감 혜택(광고 없음)이 드러난다.

**부정**
- 순서가 탑승권 아이콘 순서이자 강조 인덱스 기준이라, 중간에 끼워 넣으면 강조 대상이 바뀐다 (그래서 끝에 붙임).
- 오답 노트는 PRO 잠금이지만 여전히 목록에 없다 (DEC-0205 의 미결 사항, 이번 원본에 처리 기록 없음).

## 영향 범위 (Scope)
앱 `widgets/pro/pro_benefits.dart`, 탑승권 아이콘 줄, 구매 시트·정보 시트 혜택 줄, 광고 표시 판정.

## 출처 (References)
- GitHub #863 이슈 본문·리포트 댓글 (2026-11-07), 커밋 764b8557
