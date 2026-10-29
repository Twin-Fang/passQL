---
type: decision
id: DEC-0216
created: 2026-10-29
reviewed: null
topics: [design-system, notification]
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0168-text-only-color-tokens]]", "[[ISS-0431-app-home-top-bell-notice-banner]]", "[[ISS-0431-app-home-top-bell-notice-banner-report]]"]
---

# DEC-0216: 안 읽은 개수 배지는 iOS 시스템 빨강 + 흰 숫자로 한다 (글자 대비 4.5 기준의 조건부 예외)

## 문제 정의 (Context)
홈 종 아이콘을 강조색으로 바꾸자 옆의 주황 배지(검정 숫자)가 잘 안 보였다 (GitHub #756). 흰 숫자 대비 4.5를 지키는 진한 빨강(`#C40012`)으로 바꿨으나 작은 배지에서 여전히 잘 안 보였다. 글자 대비 4.5:1 기준은 활성 결정 [[DEC-0168-text-only-color-tokens]]이다.

## 결정 (Decision)
- 안 읽은 개수 배지(`PassqlCountBadge` 강조 상태)는 새 토큰 `countBadge`(라이트 `#FF3B30`, 다크 `#FF453A`, iOS 시스템 빨강) 위에 `onCountBadge`(흰색) 숫자를 쓴다. 흰 숫자 대비는 약 3.5:1.
- DEC-0168은 유지하고, 이 배지 숫자만 예외로 둔다 (2026-10-29 W4 확인에서 사용자가 조건부 유지 선택).
- `countBadge`는 배지 채움 전용이며 글자색으로 재사용하지 않는다.

## 검토한 대안 (Alternatives)
- 주황 유지 + 바탕색 테두리: 종과 분리는 되나 색 문제는 남음.
- 빨강 + 흰 숫자 + 바탕색 테두리 2pt: 적용해 봤으나 사용자가 "별로"라 테두리 제거.
- 진한 빨강 `#C40012`(흰 숫자 대비 6.4): 기준은 지키지만 "잘 안 보인다"는 사용자 판단으로 밝은 빨강 선택.

## 결과 (Consequences)
**긍정**
- 알림 배지가 라이트·다크 모두 눈에 잘 띄고 iOS 사용자에게 익숙하다.

**부정**
- 배지 숫자(12pt semibold)가 글자 대비 4.5 기준에 못 미친다. 대비 테스트를 도입하면 이 토큰은 예외로 등록해야 한다.

## 영향 범위 (Scope)
- `app/lib/presentation/design/tokens/passql_colors.dart`(`countBadge`, `onCountBadge`), `components/passql_count_badge.dart`
- 사용처: 홈 종 버튼(`PassqlNotificationBellButton`), 알림함 세그먼트 탭 배지

## 출처 (References)
- 이슈: [[ISS-0431-app-home-top-bell-notice-banner]] (GitHub #756), 리포트 [[ISS-0431-app-home-top-bell-notice-banner-report]]
