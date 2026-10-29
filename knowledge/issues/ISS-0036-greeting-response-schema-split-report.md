---
type: completion-report
id: ISS-0036
created: 2026-04-10
topics: [home]
status: resolved
resolves: "[[ISS-0036-greeting-response-schema-split]]"
related: ["[[DEC-0034-greeting-nickname-template-message-type]]", "[[DEC-0035-greeting-dday-weighted-mix]]"]
source: "https://github.com/Twin-Fang/passQL/issues/53"
---

# ISS-0036 완료 리포트: 인사말 응답을 `nickname`·`message`·`messageType` 3필드로 분리

GitHub #53 `## 개요` 리포트 댓글(2026-04-10, 백엔드)과 프론트 연동 댓글(2026-04-10) 기준.

## 해결 방법
- 백엔드: `GreetingResponse`를 `record GreetingResponse(String nickname, String message, GreetingMessageType messageType)`로 변경하고 `GreetingMessageType` enum(`GENERAL`, `COUNTDOWN`, `URGENT`, `EXAM_DAY`)을 신설. 메시지 풀 전체를 `{nickname}님` 플레이스홀더로 바꾸고 이모지 13종 제거. 회원 조회 실패·`memberUuid == null`·닉네임 공백이면 `FALLBACK_NICKNAME = "회원"` + `GENERAL`. D-day 구간은 `weightedPick(primary, primaryWeight, fallback, fallbackWeight)`로 가중 혼합. `GreetingServiceTest`에 폴백·반복 호출 다양성 케이스 추가, `HomeControllerDocs`에 `@ApiLog` 추가.
- 프론트: `src/pages/Home.tsx`에서 `greeting.message.replace("{nickname}", greeting.nickname)`로 치환하고 `messageType`별 서브텍스트(EXAM_DAY "오늘 시험이에요!", URGENT "시험이 얼마 남지 않았어요", COUNTDOWN "시험 D-{N}", GENERAL 없음)를 표시. `.claude/rules/api-guide.md` 갱신. 닉네임 별도 스타일링과 `messageType`별 아이콘 매핑은 미적용. `npm run build` 통과.

## 근본 원인 (확정)
이슈 노트와 같다 — 완성 문자열 하나뿐인 응답, 단일 풀 선택, 회원 조회 실패 예외.

## 재발 방지
리포트 주의사항: 응답 스키마가 breaking change라 `message`를 그대로 렌더하면 `{nickname}` 리터럴이 노출된다. `examScheduleRepository.findFirstByIsSelectedTrue()`는 전역 1건 선택을 가정하므로 회원별 선택 시험 모델로 바뀌면 함께 손봐야 한다(이번 범위 밖).

## 교훈
(원본에 없음, 볼트 정리) 화면에 `{nickname}` 리터럴이 보이면 인사말 템플릿 치환이 빠진 렌더 경로부터 본다.
