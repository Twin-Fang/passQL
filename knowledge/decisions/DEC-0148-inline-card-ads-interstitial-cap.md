---
type: decision
id: DEC-0148
created: 2026-10-18
reviewed: null
topics: [ads]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0320-ads-cards-notification-sheet-home]]", "[[ISS-0320-ads-cards-notification-sheet-home-report]]", "[[DEC-0153-single-native-strip-under-tab-bar]]"]
---

# DEC-0148: 홈·통계에는 앱 카드 모양 인라인 광고, 전면 광고는 첫 결과 2회 건너뛰고 5분 간격·하루 3회

## 문제 정의 (Context)
탭 하단 상시 배너가 앱을 지저분하게 보이게 했고, 네이티브 광고가 다른 카드와 모양이 달랐다 (GitHub #522).

## 결정 (Decision)
- 상시 배너는 없애고 홈 중간("학습 현황" 아래)과 통계 맨 아래에 카드 모양 광고(`AdInlineCard`)를 둔다. 광고가 없거나 실패하면 자리를 차지하지 않는다.
- 네이티브 광고는 미디어 120x120 이상, 앱 카드와 같은 모양(앱이 직접 그리는 팩토리).
- 전면 광고: 설치 후 첫 결과 2회는 건너뛰고, 간격을 3분에서 5분으로 늘리며, 하루 3회는 유지한다.
- 탭 셸 하단은 GitHub #527의 한 줄 띠 방식을 쓴다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 목표: "미적 일관성을 지키면서 납득할 만한 수익 선".)

## 결과 (Consequences)
**긍정**
- AdMob 검증기 경고 "MediaView is too small for video" 해소.

**부정**
- 네이티브 광고 글꼴은 Pretendard가 아니라 시스템 글꼴이다.

## 영향 범위 (Scope)
앱 `AdInlineCard`, 네이티브 팩토리 `passqlNativeCard`(Android·iOS), 전면 빈도 제한. GitHub #506의 초기 배치(탭별 하단 배너, 전면 3분 간격)를 바꿨다.

## 출처 (References)
- GitHub #522 이슈 본문, 개요 댓글 (2026-10-18)
- [[ISS-0320-ads-cards-notification-sheet-home]]
