---
type: issue
id: ISS-0020
created: 2026-04-08
topics: [home]
symptoms: ["홈 인사말", "/api/home/greeting", "D-day 분기", "시간대 메시지", "하드코딩 인사말"]
root_cause: "인사말을 하드코딩하면 시간대·시험 D-day 컨텍스트를 반영할 수 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0020-home-greeting-api-report]]"
related: ["[[DEC-0015-zero-business-logic-in-frontend]]"]
source: "https://github.com/Twin-Fang/passQL/issues/24"
---

# ISS-0020: 홈 화면 인사말 API (Greeting)

GitHub #24 (원본: 이슈 본문과 댓글).

## 증상
홈 상단 "안녕하세요, {닉네임}님"을 하드코딩하면 시간대·시험 D-day를 반영할 수 없었다. "프론트 비즈니스 로직 제로 원칙"에 따라 인사말 문장 자체를 백엔드가 완성해야 한다고 적었다.
제안: `GET /api/home/greeting?memberUuid=` → `{ message }`. D-day 분기(당일 / 1~7 / 8~30 / 그 외)와 시간대 메시지 풀 랜덤 조합. 자격증명(`SQLD`, `SQLP`)은 그대로 노출. 메시지 풀은 우선 코드 상수, 추후 `app_setting` 또는 별도 테이블 이전 검토.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-08: `## 개요` 리포트 댓글 (아래 리포트).

## 근본 원인
해당 없음 (기능 이슈).
