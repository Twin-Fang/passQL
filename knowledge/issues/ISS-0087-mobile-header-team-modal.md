---
type: issue
id: ISS-0087
created: 2026-04-12
topics: [home, design-system]
symptoms: ["모바일 상단 헤더 없음", MobileHeader, TeamModal, AppLayout, createPortal, "모달 stacking context", "fixed inset-0 갇힘"]
root_cause: "기능 추가 — 모바일은 하단 탭만 있어 상단에 앱 정체성 표시가 없었다"
status: resolved
resolution: "[[ISS-0087-mobile-header-team-modal-report]]"
related: ["[[DEC-0061-no-inline-style-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/157"
---

# ISS-0087: 모바일 홈 상단 헤더 및 팀 모달 구현

GitHub #157 (원본: 이슈 본문과 리포트 댓글).

## 증상
모바일 홈 상단에 헤더가 없어 앱 정체성이 불분명하다. 데스크톱은 좌측 사이드바에 로고가 있지만 모바일은 하단 탭만 있다 (`client/src/components/AppLayout.tsx`).

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-12: 이슈 본문 제안 — 모바일 전용 sticky `MobileHeader`(좌측 `logo.png`, 우측 팀 뱃지, 56px, `sticky top-0 z-50`), 팀 모달 `TeamModal`(팀명·멤버, Mock 하드코딩, API 없음). 데스크톱 변경 없음.

## 근본 원인
해당 없음 (기능 추가).
