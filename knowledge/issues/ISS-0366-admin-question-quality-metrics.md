---
type: issue
id: ISS-0366
created: 2026-10-24
topics: ["admin", "question-bank"]
symptoms: ["문제 품질 지표", "정답률", "풀이 수", "신고 수", "신고 많은 문제", "관리자 문제 목록 정렬"]
root_cause: "관리자 문제 목록·상세에 품질 지표(정답률·풀이 수·신고 수)와 정렬 선택이 없었다"
status: resolved
resolution: "[[ISS-0366-admin-question-quality-metrics-report]]"
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/611"
---

# ISS-0366: 관리자 문제 목록·상세에 정답률·풀이 수·신고 수가 없고 정렬이 최신순 고정

GitHub #611 (원본: 이슈 본문과 통합 구현 보고서 댓글).

## 증상
문제 목록·상세에 정답률, 풀이 수, 신고 수가 없어 품질이 나쁜 문제를 찾기 어렵다. 목록 정렬은 최신순으로 고정돼 있다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 문제별 정답률·풀이 수·신고 수 집계 쿼리(공통 지점 1곳, 목록·상세·챌린지에서 재사용), 목록 컬럼·'신고 많은 문제' 필터·정렬 선택, 상세에 보기별 선택 분포·신고 요약과 신고 상세 링크·선택지 세트 비활성화 링크.
- 2026-10-24: #611~#631 통합 구현 보고서 댓글(PR #634). #611은 완료.

## 근본 원인
기능 이슈. 해당 기능이 없었다(원본 「현재 문제점」 기준). 코드상 원인은 원본에 적혀 있지 않다.
