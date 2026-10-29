---
type: completion-report
id: ISS-0260
created: 2026-10-15
topics: [design-system]
status: resolved
resolves: "[[ISS-0260-tab-bar-bottom-padding-reduce]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/454"
---

# ISS-0260 완료 리포트: 탭바 44 + inset 60%, iPhone 16 Pro 83pt → 64pt

GitHub #454 구현 보고서 댓글(2026-10-15) 기준. 배포 v0.9.0(`555a81a`).

## 해결 방법
- `PqSize.tabBar`: 49 → **44** (터치 영역 최소 44 유지).
- `PqTabBar`: `SafeArea` 제거, `_bottomPadding` 계산 — 홈 인디케이터(iOS 34)·제스처 바(Android 약 24)면 inset의 **60%**(34→20, 24→14), inset이 40보다 크면(Android 3버튼) **inset 전체 유지**, inset 없으면 최소 8.
- `Scaffold.bottomNavigationBar`라 본문 하단 여백은 자동 조정.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: `flutter test` 224개 통과(기대값 `49+34` → `44 + 34×0.6`, 3버튼 inset 48 케이스 추가). inset을 `viewPadding`에서 `padding`으로 바꾼 뒤 하단 300px 픽셀 비교 동일.
- 주의(원본): 3버튼 판정 기준 40(3버튼 보통 48dp, 제스처 바 16~24dp), inset은 `padding` 기준(키보드가 올라오면 0이 되는 기존 `SafeArea` 동작 유지), 탭 글자를 다시 보이게 하면 높이 49 복귀 검토.

## 교훈
원본에 적혀 있지 않다.
