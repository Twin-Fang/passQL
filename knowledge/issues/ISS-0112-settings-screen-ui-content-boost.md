---
type: issue
id: ISS-0112
created: 2026-04-12
topics: [community, design-system]
symptoms: ["설정 화면", Settings.tsx, "빈약한 화면", TeamModal, "건의사항", useOnline]
root_cause: "설정 화면이 MVP 수준(카드 1개 + 로고 + 카피라이트)에 머물러 있었다"
status: resolved
resolution: "[[ISS-0112-settings-screen-ui-content-boost-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/198"
---

# ISS-0112: 설정 화면 UI 개선 — 콘텐츠 보강과 시각적 완성도

GitHub #198 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
설정 화면이 카드 1개(디바이스 ID / 닉네임 / 버전) + 로고 + 카피라이트뿐. 브랜드·UX 배려 부족, 시험 일정 선택·앱 소개 같은 콘텐츠 없음, TeamModal이 헤더 버튼에 숨어 노출도가 낮음.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: 계정/앱 정보/기타 섹션 구분, 시험 일정 선택(`/exam-schedules`), 팀 소개 직접 노출, 브랜딩 강화.
- 2026-04-12: 실제 구현은 계정 / 건의사항 / 앱 정보 / 개발자 4개 섹션(리포트). 이슈 본문의 시험 일정 선택·팀 소개 노출이 구현됐는지는 리포트에 적혀 있지 않다.

## 근본 원인
원본에 적혀 있지 않다 (UI 개선 요청).
