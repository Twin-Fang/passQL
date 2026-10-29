---
type: issue
id: ISS-0088
created: 2026-04-12
topics: [home]
symptoms: ["greeting 한 줄", "닉네임 강조 없음", "애니메이션 없음", GreetingService, parseGreetingLines, greetingIn]
root_cause: "기능 개선 — greeting 메시지가 줄바꿈 없이 한 줄로 길고, 닉네임 강조·등장 애니메이션이 없었다"
status: resolved
resolution: "[[ISS-0088-home-greeting-linebreak-fadein-report]]"
related: ["[[ISS-0091-stagger-fadein-tab-sections]]"]
source: "https://github.com/Twin-Fang/passQL/issues/158"
---

# ISS-0088: 홈 Greeting 메시지 줄바꿈, 닉네임 강조, 페이드인 애니메이션

GitHub #158 (원본: 이슈 본문과 리포트 댓글).

## 증상
홈 greeting 메시지가 한 줄로 길게 이어져 가독성이 떨어지고, 애니메이션 없이 즉시 나타나며, 닉네임이 본문과 같은 스타일이다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 본문 제안 — 백엔드가 `message`에 `\n` 삽입, 프론트가 `\n` split과 `{nickname}` span 강조(브랜드 인디고), 페이드인 + 슬라이드업(400ms ease-out), 서브 메시지 80ms 딜레이.

## 근본 원인
해당 없음 (기능 개선).
