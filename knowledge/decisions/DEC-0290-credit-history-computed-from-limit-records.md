---
type: decision
id: DEC-0290
created: 2026-11-12
reviewed: null
topics: [billing, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0493-credit-history-screen]]", "[[DEC-0287-credit-term-top-bar-balance]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]"]
---

# DEC-0290: 크레딧 내역은 따로 저장하지 않고, 한도 판정이 쓰는 원본 기록에서 같은 메서드로 날짜별로 계산해 보여 준다

## 문제 정의 (Context)
[[DEC-0287-credit-term-top-bar-balance]]는 프로필 오늘 크레딧에 오늘 내역 시트만 두고 "지난 날짜 내역은 없다"고 했다. 날짜별 내역은 서버 기록 테이블이 필요해 그때 미뤘고, GitHub #974로 떼어 냈다. 이슈는 크레딧 내역(받음·씀) 기록 테이블을 제안했다.

## 결정 (Decision)
- 크레딧 내역 테이블·마이그레이션을 만들지 않는다. 기존 제출·오늘의 세트·광고 보너스 기록을 날짜별로 모아 계산한다(`CreditHistoryService`, `GET /api/members/me/credit-history?days=N`, 기본 14일, 1~30일).
- 오늘 한도 판정과 내역은 같은 메서드(`DailyQuestionCounter.countRandomSolvedByDate`, `DailyFreeBonusReader.readByDate`)를 쓴다.
- 앱 프로필 오늘 크레딧 「내역」은 날짜별 내역 화면이다. [[DEC-0287-credit-term-top-bar-balance]]의 "오늘 내역 시트, 지난 날짜 내역 없음" 부분만 이것으로 바꾼다(그 결정의 나머지는 유지).
- 출시된 앱이 읽는 응답 필드 이름은 그대로 둔다(이슈 본문, 호환).

## 검토한 대안 (Alternatives)
- 크레딧 내역 기록을 따로 저장(이슈 제안): 기록을 하나 더 두면 한도 판정과 어긋날 수 있어 버렸다(리포트 「왜 이렇게 했나」).
- 보관 기간·기록 시점 설계(이슈 작업 항목)는 저장하지 않기로 해 필요 없어졌다. 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 상단 크레딧 수와 내역 오늘 줄이 어긋날 수 없다. 읽기 전용이라 운영 DB가 바뀌지 않아 배포 위험이 낮다.

**부정**
- 새 보너스 종류가 생기면 `CreditHistoryService`의 보너스 항목 목록에 함께 추가해야 한다.
- 리포트에 적힌 응답 필드는 날짜별 합계뿐이다. 이슈가 제안한 받은·쓴 "시각"은 리포트에 나오지 않는다.

## 영향 범위 (Scope)
- 서버 `CreditHistoryService`, `DailyQuestionCounter`, `DailyFreeBonusReader`, `api-contract/openapi.json`.
- 앱 `CreditHistoryPage`, `creditHistoryProvider`, `buildCreditHistoryEntries`.

## 출처 (References)
- GitHub #974 이슈 본문과 구현 보고(PR #978): https://github.com/Twin-Fang/passQL/issues/974
