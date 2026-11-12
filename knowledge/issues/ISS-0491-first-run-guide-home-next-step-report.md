---
type: completion-report
id: ISS-0491
created: 2026-11-12
topics: [home, auth-member, practice, design-system]
status: resolved
resolves: "[[ISS-0491-first-run-guide-home-next-step]]"
related: ["[[DEC-0287-credit-term-top-bar-balance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/975"
---

# ISS-0491 완료 리포트: 로그인 차별점, 홈 다음에 할 일 카드, 환영 안내 시트

## 해결 방법
서버 변경 없이 앱에서 1차.
- 로그인 첫 화면: 한 줄 "SQL을 직접 실행하고 AI와 함께 푸는 SQLD" + 세 가지(직접 실행, AI 해설, 풀 때마다 AI 새 보기). 실제로 있는 기능만 적음("무제한 문제 생성"은 쓰지 않음).
- 홈 맨 위 `다음에 할 일` 카드: 오늘의 세트 > 랜덤 풀기(남은 크레딧) > 크레딧 받기 순으로 한 가지만. 판정은 `decideHomeNextStep`(순수 함수, 테스트). 홈의 채운 버튼은 이 카드 하나.
- 홈 첫 방문 환영 안내 시트(기기에서 한 번).
- 온보딩 마지막 장을 5문제 실력 확인 안내로, 준비도 일정 문구를 실제에 맞게.

## 근본 원인 (확정)
첫 화면·홈에 차별점과 지금 할 일이 없었고 무료 회원 안내 구간이 없었다.

## 재발 방지
- 홈에 새 행동 유도를 넣을 때는 `다음에 할 일` 판정에 넣는다(채운 버튼을 여러 개 두지 않음).

## 교훈
- 남은 결정(논의 기록 없음, 사용자 답 대기): 무료 회원이 오늘의 세트에서 직접 실행·AI 해설을 체험하게 할지. 첫 화면에서 알리는 기능이 무료에서는 전부 잠겨 있다.
