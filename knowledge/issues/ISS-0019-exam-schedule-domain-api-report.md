---
type: completion-report
id: ISS-0019
created: 2026-04-08
topics: [home, admin]
status: resolved
resolves: "[[ISS-0019-exam-schedule-domain-api]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/23"
---

# ISS-0019 완료 리포트: `ExamScheduleService` 분리, 사용자·어드민 API와 Thymeleaf 화면

GitHub #23 `## 개요` 리포트 댓글(2026-04-08) 기준.

## 해결 방법
- `MetaController`/`MetaService`에 임시로 있던 exam-schedule 로직을 전용 `ExamScheduleService`로 분리(단일 책임). Entity 직접 반환 → `ExamScheduleResponse` DTO.
- 사용자 API: `GET /api/exam-schedules?certType=SQLD`, `GET /api/exam-schedules/selected`(없으면 200 + null, 404 아님).
- 어드민: `GET /admin/exam-schedules`(화면), `POST`(회차 추가, `certType`+`round` 중복 시 409 `EXAM_SCHEDULE_DUPLICATE`), `PUT /{uuid}/select`(선택 토글), `DELETE /{uuid}`(자동 재선택 없음). `templates/admin/exam-schedules.html`, 사이드바 "시험 일정" 메뉴.
- 단일 선택 불변식: 이슈 본문은 부분 unique index를 제안했지만, 리포트는 "MySQL에 부분 unique index가 없으므로" `@Transactional` `selectSchedule()`에서 기존 선택을 false로 바꾼 뒤 대상을 true로 설정해 서비스 레이어에서 보장했다.
- `exam_schedule` DDL과 SQLD 60~63회 시드는 `V0_0_22`에 이미 포함되어 별도 마이그레이션 없음.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 주의사항: 선택된 행을 삭제해도 자동 재선택이 없으므로 홈 인사말에서 fallback 처리가 필요. `version.yml` 0.0.23 업데이트는 별도로 수행해야 한다.

## 교훈
(원본에 없음, 볼트 정리) MySQL/MariaDB에는 부분 unique index가 없으므로 "한 행만 선택" 같은 불변식은 DB 제약이 아니라 트랜잭션 로직으로 지켜진다 — 선택 플래그를 직접 UPDATE하는 경로가 있으면 깨질 수 있다.
