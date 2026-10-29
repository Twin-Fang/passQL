---
type: issue
id: ISS-0367
created: 2026-10-24
topics: ["admin", "question-bank"]
symptoms: ["문제 일괄 활성화", "일괄 토픽 변경", "일괄 난이도 변경", "CSV 내보내기", "JSON 내보내기만"]
root_cause: "관리자 화면에 해당 운영 기능이 없었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/612"
---

# ISS-0367: 관리자 문제 일괄 처리(활성화·토픽·난이도)와 CSV 내보내기가 없음

GitHub #612 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
문제 일괄 활성화(복구)는 행별 버튼뿐이고, 일괄 토픽·난이도 변경이 없다. 내보내기가 JSON뿐이다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 일괄 활성화 API와 UI, 일괄 토픽·난이도 변경 API와 UI, 목록 CSV 내보내기.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 문제 일괄 활성화, 일괄 토픽·난이도 변경 완료. CSV 내보내기는 미적용. 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.
- 남은 일(#611 리포트): CSV 내보내기를 목록 화면(문제·회원·건의)에 적용. 공통 유틸 `AdminCsvResponseWriter`는 있음.

## 근본 원인
기능 이슈. 해당 기능이 없었다(원본 「현재 문제점」 기준). 코드상 원인은 원본에 적혀 있지 않다.
