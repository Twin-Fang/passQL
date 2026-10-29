---
type: issue
id: ISS-0375
created: 2026-10-24
topics: ["admin"]
symptoms: ["리텐션 없음", "D1 D7 D30 리텐션", "가입 주차별 코호트", "기능별 사용률", "방문자 수만"]
root_cause: "관리자 화면에 해당 운영 기능이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/620"
---

# ISS-0375: 관리자 통계에 리텐션·코호트·기능 사용률이 없음 (방문자 수만)

GitHub #620 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
방문자 수만 있고 리텐션·코호트·기능 사용률이 없다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: D1/D7/D30 리텐션, 가입 주차별 코호트, 기능별 사용률.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 리텐션·코호트·기능 사용률 완료. 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.

## 근본 원인
기능 이슈. 해당 기능이 없었다(원본 「현재 문제점」 기준). 코드상 원인은 원본에 적혀 있지 않다.
