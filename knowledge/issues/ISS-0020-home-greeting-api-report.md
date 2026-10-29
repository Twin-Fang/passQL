---
type: completion-report
id: ISS-0020
created: 2026-04-08
topics: [home]
status: resolved
resolves: "[[ISS-0020-home-greeting-api]]"
related: ["[[DEC-0015-zero-business-logic-in-frontend]]"]
source: "https://github.com/Twin-Fang/passQL/issues/24"
---

# ISS-0020 완료 리포트: `GreetingService`가 D-day·시간대별 풀에서 랜덤 인사말 한 문장을 반환

GitHub #24 `## 개요` 리포트 댓글(2026-04-08) 기준.

## 해결 방법
- `GreetingResponse(String message)`(PQL-Application), `GreetingService`, `HomeController`(`GET /api/home/greeting`, `memberUuid` 필수, 없거나 탈퇴 회원은 404), `GreetingServiceTest`(SpringBootTest 통합), `docs/apilog/2026-04-08-add-home-greeting.md`.
- `ExamScheduleRepository.findFirstByIsSelectedTrue()` + `ChronoUnit.DAYS.between(today, examDate)`로 D-day.
- 풀: dDay == 0 → 4종, 1~7 → 5종, 8~30 → 6종, dDay > 30·dDay < 0·시험 미선택 → 일반 인사 8종(D-day 숫자 미노출, 시간대 아침 5–11 / 오후 11–17 / 저녁 17–22 / 심야). `ThreadLocalRandom`으로 매 요청 랜덤.
- `HomeService`는 수정하지 않고 Greeting 전용 서비스로 분리.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 주의사항: D-day > 30과 시험 없음은 같은 일반 풀(D-day 숫자 미노출이 의도). 선택 시험이 지난 날짜면 일반 풀로 fallthrough, 다음 시험 선택은 관리자가 수동. 메시지는 서비스 코드에 하드코딩 — 수정이 잦으면 외부 설정 분리 고려.

## 교훈
원본에 적혀 있지 않다.
