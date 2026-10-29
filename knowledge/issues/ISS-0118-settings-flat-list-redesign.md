---
type: issue
id: ISS-0118
created: 2026-04-13
topics: [design-system]
symptoms: ["설정 카드 레이아웃", Settings.tsx, SettingsRow, SettingsSection, isLast, divide-y, "flat 리스트"]
root_cause: "설정 화면이 카드 컨테이너 중심이라 항목이 늘수록 카드가 중첩되어 무거워지는 구조였다"
status: resolved
resolution: "[[ISS-0118-settings-flat-list-redesign-report]]"
related: ["[[DEC-0071-settings-flat-grouped-list]]"]
source: "https://github.com/Twin-Fang/passQL/issues/211"
---

# ISS-0118: Settings 페이지 flat 스타일 리디자인

GitHub #211 (원본: 이슈 본문과 작업 리포트 댓글). 선행 작업 GitHub #209.

## 증상
`Settings.tsx`가 카드(`bg-surface-card border rounded-2xl`) 기반. iOS 설정 앱·토스 등 표준 모바일 패턴과 다르고, 항목이 늘수록 카드가 중첩되어 시각적으로 무겁다(이슈 본문).

## 재현 조건
해당 없음 (디자인 개선).

## 조사 기록
- 2026-04-13: 이슈 등록과 구현(리포트).

## 근본 원인
카드 컨테이너 중심 레이아웃.
