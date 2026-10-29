---
type: issue
id: ISS-0372
created: 2026-10-24
topics: ["admin", "practice"]
symptoms: ["일일 챌린지 배정 후보 200개 고정", "AdminDailyChallengeController", "날짜 한 건씩 배정", "기간 일괄 배정", "비활성 문제 배정 경고"]
root_cause: "관리자 화면에 해당 운영 기능이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/617"
---

# ISS-0372: 관리자 일일 챌린지 배정 — 후보가 최신 200개로 고정되고 날짜 한 건씩만 배정

GitHub #617 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
배정 후보가 최신 활성 문제 200개로 고정돼 있다(`AdminDailyChallengeController.java:23`). 날짜 한 건씩만 배정할 수 있다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 후보 검색·토픽·난이도 필터, 기간 일괄 자동 배정과 복사, 배정 문제의 정답률·난이도 분포 표시, 비활성 문제가 배정돼 있을 때 경고.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 일일 챌린지 후보 검색, 기간 일괄 배정·복사, 난이도 분포, 경고 완료. 정답률 표시는 미적용. 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.

## 근본 원인
기능 이슈. 해당 기능이 없었다(원본 「현재 문제점」 기준). 코드상 원인은 원본에 적혀 있지 않다.
