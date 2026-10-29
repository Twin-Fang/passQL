---
type: issue
id: ISS-0019
created: 2026-04-08
topics: [home, admin]
symptoms: ["시험 D-day", exam_schedule, "시험 일정 도메인 없음", SQLD, SQLP, "선택 회차"]
root_cause: "홈 인사말 시험 D-day 계산에 필요한 시험 일정 도메인이 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0019-exam-schedule-domain-api-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/23"
---

# ISS-0019: SQLD/SQLP Exam Schedule 도메인 및 시험 일정 관리 API

GitHub #23 (원본: 이슈 본문과 댓글).

## 증상
홈 인사말의 "시험 D-day"를 계산하려면 시험 일정을 DB로 관리해야 하는데 도메인이 없었다. 자격증 종류·회차별 일정을 한 곳에서 관리하고 "목표 시험" 1개를 고를 수 있어야 했고, 코드 프리즈 이후에도 회차 등록/선택 변경이 가능하도록 어드민 화면이 필요했다.
제안: `exam_schedule` 테이블, 시스템 전체에서 한 회차만 `is_selected = true`(부분 unique index로 강제), SQLD 60~63회 시드(61회 2026-05-31 기본 선택), 사용자 API(`GET /api/exam-schedules?certType=SQLD`, `GET /api/exam-schedules/selected`)와 어드민 CRUD·선택 토글.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-08: `## 개요` 리포트 댓글 (아래 리포트), 이어서 화면 캡처 3장.

## 근본 원인
해당 없음 (기능 이슈).
