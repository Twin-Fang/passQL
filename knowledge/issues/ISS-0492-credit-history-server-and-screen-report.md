---
type: completion-report
id: ISS-0492
created: 2026-11-12
topics: [billing, practice]
status: resolved
resolves: "[[ISS-0492-credit-history-server-and-screen]]"
related: ["[[DEC-0287-credit-term-top-bar-balance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/974"
---

# ISS-0492 완료 리포트: 날짜별 크레딧 내역 API와 내역 화면 (PR #978)

## 해결 방법
- 서버 `GET /api/members/me/credit-history?days=N`(기본 14, 1~30). 날짜마다 기본·세트 완료·세트 정답 80%·광고(횟수와 크레딧)·쓴 수·남은 수. 읽기 전용, 마이그레이션 없음.
- 오늘 한도 판정과 내역이 같은 메서드(`DailyQuestionCounter.countRandomSolvedByDate`, `DailyFreeBonusReader.readByDate`)를 쓴다.
- 앱: 프로필 오늘 크레딧 「내역」 > 날짜별 내역 화면(오늘·어제·날짜 머리 + 그날 남은 수, 받은 줄 +N, 쓴 줄 -N). 줄 계산은 순수 함수 `buildCreditHistoryEntries`.
- API 계약·웹 타입 갱신. 2026-11-12 1.102.0 배포, 운영에서 경로 응답(비로그인 401) 확인.

## 근본 원인 (확정)
날짜별 내역 API 부재.

## 재발 방지
- 새 보너스 종류를 만들면 한도 판정과 `CreditHistoryService`의 보너스 항목을 함께 추가한다(판정 메서드는 공유).

## 교훈
- 내역을 따로 저장하지 않고 판정이 쓰는 원본 기록에서 같은 메서드로 계산하면, 상단 숫자와 내역이 어긋날 수 없다.
