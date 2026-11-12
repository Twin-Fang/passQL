---
type: completion-report
id: ISS-0493
created: 2026-11-12
topics: [billing, practice]
status: resolved
resolves: "[[ISS-0493-credit-history-screen]]"
related: ["[[DEC-0290-credit-history-computed-from-limit-records]]"]
source: "https://github.com/Twin-Fang/passQL/issues/974"
---

# ISS-0493 완료 리포트: 날짜별 크레딧 내역 (새 테이블 없이 계산)

GitHub #974 구현 보고 (2026-11-12). PR #978 머지(2026-11-12).

## 해결 방법
- **서버:** `GET /api/members/me/credit-history?days=N` (기본 14일, 1~30일). 날짜마다 `baseCredits`, `dailySetCompletionCredits`, `dailySetAccuracyCredits`, `adBonusCount`·`adBonusCredits`, `usedCredits`, `remainingCredits`. 새 테이블·마이그레이션 없이 기존 제출·오늘의 세트·광고 보너스 기록을 날짜별로 모아 계산한다(`CreditHistoryService`).
- **같은 계산 공유:** `DailyQuestionCounter.countRandomSolvedByDate`와 `DailyFreeBonusReader.readByDate`를 오늘 한도 판정과 내역이 함께 쓴다. 상단 크레딧 수와 내역의 오늘 줄이 어긋날 수 없다.
- **앱:** 프로필 > 오늘 크레딧 「내역」이 날짜별 내역 화면(`CreditHistoryPage`)으로 열린다(전에는 오늘만 보이는 시트). 날짜 머리는 오늘·어제·날짜 + 그날 남은 크레딧, 받은 줄 `+N`, 쓴 줄 `-N`. 줄 계산은 순수 함수 `buildCreditHistoryEntries`.
- **API 계약:** `api-contract/openapi.json` 갱신, 웹 타입 재생성.

## 근본 원인 (확정)
날짜별 내역을 만드는 곳이 없었다. 원본 기록은 이미 있어 계산으로 해결했다.

## 재발 방지
- 새 보너스 종류가 생기면 `CreditHistoryService`의 보너스 항목 목록도 함께 추가한다. 한도 판정 규칙은 같은 메서드를 써서 따로 고칠 곳이 없다.
- 날짜 경계는 서버의 오늘 판정 기준(한국 시간)을 따른다.

## 교훈
- 검증: 서버 `CreditHistoryServiceTest`, `DailyFreeBonusReaderTest`, `DailyQuestionCounterTest`, `OpenApiContractTest`; 앱 `credit_history_entry_test`, `api_contract_test`, `date_format_test`, 디자인 규칙 테스트 통과. 배포 후 운영에서 비로그인 요청이 401을 받아 경로가 살아 있음을 확인.
- 이슈가 제안한 서버 코드·API 이름 정리와 관리자 회원 상세의 크레딧 내역(선택)은 리포트에 한 일로 적히지 않았다.
