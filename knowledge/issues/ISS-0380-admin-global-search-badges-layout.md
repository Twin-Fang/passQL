---
type: issue
id: ISS-0380
created: 2026-10-24
topics: ["admin", "design-system"]
symptoms: ["관리자 전역 검색 없음", "미처리 건수 뱃지", "다크모드 OS 설정", "CDN 장애 화면 깨짐", "layout.html CDN"]
root_cause: "관리자 레이아웃이 외부 CDN 라이브러리에 의존했고(`layout.html:11-17`), 전역 검색·뱃지·OS 다크모드 연동 기능이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/625"
---

# ISS-0380: 관리자 전역 검색·미처리 뱃지가 없고 다크모드가 OS를 따르지 않으며 CDN 장애 시 화면이 깨짐

GitHub #625 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
전역 검색이 없고, 미처리 건수가 대시보드에서만 보인다. 다크모드가 OS 설정을 따르지 않는다. CDN 장애 시 화면이 깨진다(`layout.html:11-17`).

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 회원·문제 UUID/닉네임 전역 검색, 사이드바 미처리 건수 뱃지·상단 알림 센터, 다크모드 OS 설정 따르기, CDN 의존 라이브러리 로컬 번들.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 전역 검색, 사이드바 뱃지, 다크모드 OS 연동, CDN 로컬 번들 완료(일부 화면 CDN 잔존). 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.
- 남은 일(#611 리포트): Chart.js, FullCalendar CDN 의존 로컬 번들.
- 통합 중: 전역 검색과 회원 응답 시그니처가 충돌해 컴파일이 깨졌고, 프로 이용 여부를 같이 계산하도록 고침.

## 근본 원인
CDN 장애 시 깨지는 것은 `layout.html:11-17`의 CDN 의존 때문(원본 「현재 문제점」). 나머지는 기능 미구현.
