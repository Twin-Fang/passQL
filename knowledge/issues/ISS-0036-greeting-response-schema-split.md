---
type: issue
id: ISS-0036
created: 2026-04-10
topics: [home]
symptoms: [GreetingResponse, "/home/greeting", "닉네임 스타일링 불가", "이모지 하드코딩", "D-day 메시지 반복", MEMBER_NOT_FOUND]
root_cause: "인사말 응답이 닉네임·본문·이모지를 한 문자열로 내려주고, D-day 구간은 단일 풀만 쓰며, 회원 조회 실패 시 예외를 던졌다"
status: resolved
resolution: "[[ISS-0036-greeting-response-schema-split-report]]"
related: ["[[DEC-0034-greeting-nickname-template-message-type]]", "[[DEC-0035-greeting-dday-weighted-mix]]"]
source: "https://github.com/Twin-Fang/passQL/issues/53"
---

# ISS-0036: 홈 인사말 응답이 닉네임·본문·이모지를 한 문자열로 내려주고 D-day 구간엔 긴급 메시지만 반복

GitHub #53 (원본: 이슈 본문과 댓글).

## 증상
`GreetingResponse`가 `{ message: "홍길동님, 좋은 아침이에요! ... 📚" }`처럼 닉네임·본문·이모지를 한 문자열로 내려준다. 프론트가 닉네임만 따로 스타일링하려면 문자열 파싱이 필요하다. 이모지(📚 💪 🔥 ✨ 🎯 등)가 하드코딩되어 프론트가 아이콘·톤을 일관되게 적용하기 어렵다. D-7·D-30 이내 구간에서는 "D-5 스퍼트!" 같은 긴급 메시지만 반복 노출된다. 회원 조회 실패 시 `MEMBER_NOT_FOUND` 예외를 던져 홈 인사말 fallback 요구를 못 맞춘다.

## 재현 조건
해당 없음 (기능 개선 이슈). D-day 반복은 시험 D-30 이내에 매일 접속할 때.

## 조사 기록
- 2026-04-10: 이슈 본문이 응답 3필드 분리, 이모지 제거, 예외 fallback, D-day 가중치 혼합을 제안.
- 2026-04-10: 백엔드 `## 개요` 리포트 댓글, 같은 날 프론트 연동 댓글.

## 근본 원인
응답이 렌더링용 완성 문자열 하나였고, 메시지 선택이 구간 단위 단일 풀이었으며, 회원 조회 실패를 예외로 처리했다.
