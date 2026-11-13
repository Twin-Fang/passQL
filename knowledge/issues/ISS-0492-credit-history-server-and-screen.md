---
type: issue
id: ISS-0492
created: 2026-11-12
topics: [billing, practice]
symptoms: ["크레딧 사용 내역", "크레딧이 왜 이만큼 남았지", "오늘만 보이는 내역 시트", "credit-history", "credit_today_history_sheet", "CreditHistoryService"]
root_cause: "크레딧 받은 수·쓴 수를 날짜별로 돌려주는 서버 API가 없어 앱은 오늘 하루만 시트로 보여줄 수 있었다"
status: resolved
resolution: "[[ISS-0492-credit-history-server-and-screen-report]]"
related: ["[[DEC-0287-credit-term-top-bar-balance]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]"]
source: "https://github.com/Twin-Fang/passQL/issues/974"
---

# ISS-0492: 크레딧 사용 내역 — 서버 기록과 내역 화면

GitHub #974.

## 증상
- 상단 크레딧 알약과 크레딧 시트는 오늘 남은 수만 보여 주고, 언제 얼마를 받고 썼는지 볼 곳이 없음.
- 프로필 오늘 크레딧의 「내역」은 오늘만 보이는 시트였음.

## 재현 조건
무료 회원, 결제 켜짐, 여러 날 랜덤 풀기·오늘의 세트·광고 보너스 사용.

## 조사 기록
- 2026-11-12: 받은 수(기본, 세트 완료, 세트 정답 80%, 광고)와 쓴 수(랜덤 풀이 제출)는 이미 제출·오늘의 세트·광고 보너스 기록에 날짜별로 남아 있음. 별도 내역 테이블 없이 계산 가능.

## 근본 원인
날짜별 크레딧 내역을 돌려주는 서버 API가 없었다.
