---
type: decision
id: DEC-0071
created: 2026-04-13
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0118-settings-flat-list-redesign]]", "[[ISS-0118-settings-flat-list-redesign-report]]", "[[DEC-0069-settings-tab-rows-only-subpages]]"]
---

# DEC-0071: 설정 화면은 카드 대신 iOS grouped 스타일 flat 리스트 (전체 너비 border-y + divide-y, 가로형 row)

## 문제 정의 (Context)
설정 화면이 카드 기반이라 항목이 늘수록 카드가 중첩되어 무거웠고, iOS 설정 앱·토스 등 표준 모바일 패턴과 달랐다 (GitHub #211 이슈 본문).

## 결정 (Decision)
- 섹션 그룹: `bg-surface-card border-y border-border divide-y divide-border` — 좌우 border·rounded 없이 전체 너비 흰 띠가 페이지 배경 위에 뜨는 구조.
- 섹션 헤더: 회색 텍스트 라벨만(장식 pill 없음). 위계는 섹션 간 여백과 구분선으로.
- Row: 가로형(label 왼쪽, value+action 오른쪽), 구분선은 부모 `divide-y`.
- DevPage도 같은 패턴.

## 검토한 대안 (Alternatives)
- 카드 컨테이너(`bg-surface-card border rounded-2xl`) 유지: 위 이유로 버림.
- 세로형 row(label 위 / value 아래): 리포트는 "iOS/토스 표준 한 줄 설정 row 패턴"이라 가로형으로 바꿨다고 적음.

## 결과 (Consequences)
**긍정**
- 항목이 늘어도 카드 중첩 없이 가볍다(이슈 본문).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
웹 `Settings.tsx`, `DevPage.tsx`, `SettingsRow.tsx`, `SettingsSection.tsx`.

## 출처 (References)
- GitHub #211 이슈 본문, 작업 리포트 (2026-04-13)
- [[ISS-0118-settings-flat-list-redesign]]
