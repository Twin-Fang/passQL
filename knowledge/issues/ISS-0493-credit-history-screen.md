---
type: issue
id: ISS-0493
created: 2026-11-12
topics: [billing, practice]
symptoms: ["크레딧 내역 없음", "지난 날짜 크레딧 내역", "오늘 크레딧 내역", "언제 받고 언제 썼는지", todayRandomSolvedCount, dailyFreeLimit, dailyBonus, credit-history]
root_cause: "서버에는 오늘 집계(오늘 푼 랜덤 문제 수, 세트 보너스 여부, 광고 보너스 횟수)만 있고, 앱 내역은 그 오늘 집계로 만든 요약이라 날짜별로 받고 쓴 내역을 볼 수 없었다"
status: resolved
resolution: "[[ISS-0493-credit-history-screen-report]]"
related: ["[[DEC-0290-credit-history-computed-from-limit-records]]", "[[DEC-0287-credit-term-top-bar-balance]]", "[[ISS-0490-credit-term-purchase-funnel-events]]"]
source: "https://github.com/Twin-Fang/passQL/issues/974"
---

# ISS-0493: 크레딧 사용 내역 (서버 기록과 내역 화면)

GitHub #974. 관련 #971([[ISS-0490-credit-term-purchase-funnel-events]]에서 떼어 낸 후속), #963.

## 증상
- 무료 한도를 `크레딧`으로 부르기로 했지만([[DEC-0287-credit-term-top-bar-balance]]), 서버에는 오늘 집계만 있고 크레딧 내역 기록이 없다.
- 앱의 "오늘 크레딧 내역"은 오늘 집계로 만든 요약이라 언제 받고 언제 썼는지, 지난 날짜 내역을 볼 수 없다.
- 서버 코드·API 이름(`todayRandomSolvedCount`, `dailyFreeLimit`, `dailyBonus`)이 크레딧이라는 말과 맞지 않는다.

## 재현 조건
프로필 > 오늘 크레딧 > 내역.

## 조사 기록
- 2026-11-12 이슈 제안: 서버에 크레딧 내역(받음·씀) 기록(회원, 종류, 수량, 시각)을 두고 날짜별·페이지 조회 API. 출시된 앱이 읽는 응답 필드는 그대로(호환).
- 하지 않는 것(이슈 본문): 크레딧 판매(스토어 소모성 상품), 한도 수치 변경.

## 근본 원인
날짜별 받고 쓴 내역을 계산하거나 저장하는 곳이 없었다.
