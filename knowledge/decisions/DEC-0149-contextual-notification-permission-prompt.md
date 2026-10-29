---
type: decision
id: DEC-0149
created: 2026-10-18
reviewed: null
topics: [notification]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0320-ads-cards-notification-sheet-home]]", "[[ISS-0320-ads-cards-notification-sheet-home-report]]"]
---

# DEC-0149: 알림 권한 안내 시트는 가입 직후가 아니라 결과 화면을 본 뒤 탭 복귀 시나 두 번째 실행부터 띄운다

## 문제 정의 (Context)
가입 직후 알림 권한 안내 시트가 홈 위에 바로 떴다 (GitHub #522).

## 결정 (Decision)
- 알림 권한은 맥락이 있는 시점에 정석 흐름(HIG)으로 묻는다(이슈 본문).
- 구현: 결과 화면을 본 뒤 탭으로 돌아올 때나 두 번째 실행부터 띄운다. 닫기 X를 없앤다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
앱 알림 권한 안내 시트 표시 조건.

## 출처 (References)
- GitHub #522 이슈 본문, 개요 댓글 (2026-10-18)
- [[ISS-0320-ads-cards-notification-sheet-home]]
