---
type: completion-report
id: ISS-0511
created: 2026-11-13
topics: [design-system, practice, home, notification]
status: resolved
resolves: "[[ISS-0511-qa-1112-ui-polish-eight]]"
related: ["[[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]", "[[DEC-0302-first-run-sheets-today-steps-notification-preview]]", "[[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]]", "[[DEC-0287-credit-term-top-bar-balance]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1041"
---

# ISS-0511 완료 리포트: 시안 추천안 8건 반영, 모의고사 순위 서버 필드 (PR #1042)

원본 사본: `_sources/issues/ISS-0511-qa-1112-ui-polish-eight-report.md`(로컬).

## 해결 방법
| # | 채택 | 구현 |
|---|---|---|
| ① | B 오늘 할 일 3단계 | 번호 원 3단계 + `오늘의 세트 시작하기`·`둘러볼게요`. 시작은 세트로 바로, 둘러보기·닫기는 기존처럼 알림 안내로 → [[DEC-0302-first-run-sheets-today-steps-notification-preview]] |
| ② | B 실제 알림 미리보기 | 원서접수 마감 D-1·신고 처리 결과 알림 카드 2개 + 보내는 종류 한 줄. 문구는 서버 알림 문구 그대로 → DEC-0302 |
| ③ | A 상위 N% 한 줄 | 서버 `MockExamResultResponse.ranking`(nullable) + 앱 점수 아래 한 줄, 무료도 공개 → [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]] |
| ④ | A 젬 그대로 | 크레딧 뜻 번개 3곳(환영 시트·잠금화면 소개·온보딩 4장) > `PassqlCreditIcon`. AI 새 보기·출제 경향 번개는 크레딧 뜻이 아니라 유지 ([[DEC-0287-credit-term-top-bar-balance]] 적용) |
| ⑤ | A 색 구분 배지 | 표 머리 이름 뒤 배지(PK 강조색, FK 주의색), 반경 토큰 `keyBadge` → [[DEC-0303-display-parts-difficulty-stars-count-up-key-badge-cutoff]] |
| ⑥ | A 아이콘 별 | `PassqlDifficultyStars`로 풀이 머리·홈 추천·프로필 3곳, 글자 별 함수 제거 → DEC-0303 |
| ⑦ | A 0부터 차오름 | `PassqlCountUp`(700ms, 값 변경 시 이전 값에서 이어짐, 동작 줄이기면 최종값) > 모의고사 총점·크레딧 잔액 → DEC-0303 |
| ⑧ | B 과목별 기준 칸 | 노란 경고 상자 > `과목별 과락 기준` 카드 + 칸 2개(`8점 이상`·`32점 이상`) → DEC-0303 |

서버(③): `MockExamRanking`(rankPosition·takerCount·topPercent), `MockExamAttemptRepository.findSubmittedScoresByRoundInSubmitOrder`(쿼리 1번, 기존 회차·상태 인덱스), `MockExamRankingCalculator`(순수 함수, `MINIMUM_RANKING_TAKER_COUNT = 10`), `openapi.json`·웹 생성 타입 갱신.

## 근본 원인 (확정)
디자인 개선 요청(결함 아님). 표시 요소 일부가 공통 부품 밖에 있었다.

## 재발 방지
- 검증: 앱 `flutter analyze` 이슈 없음, `flutter test` 172개 통과. 서버 `build -x test` 성공, `:PQL-Domain-Submission:test`·`:PQL-Application:test` 실패 0, 순위 계산 테스트 3개(10명 미만 null, 동점 같은 순위·올림, 재응시는 첫 응시만), `OpenApiContractTest` 통과.
- **시뮬레이터 실측 안 함**(여유 메모리 3.6GB < 부팅 기준 7.2GB). 렌더는 테스트 환경 위젯 캡처. 브랜치 빌드(TestFlight·APK)로 확인 필요. 첫 `@projectops app build` 댓글은 브랜치 push 전이라 "브랜치를 찾을 수 없음"으로 실패.
- 순위는 서버 배포 전에는 응답에 없어 앱에 안 보인다(구버전 서버 null).
- 알림 미리보기 문구는 서버 알림 문구의 사본(`NotificationPermissionTexts.previewNotifications`). 서버의 신고 처리 문구·원서접수 알림 제목을 바꾸면 함께 바꾼다.
- 잠금화면 소개 줄 목록은 아이콘 `null` = 크레딧 젬으로 읽는다.

## 교훈
- 요청 원문이 없을 때는 이슈 본문에 항목별 해석을 적고 시안 > 추천안 바로 구현 > 사후 확인 순으로 진행했다. 해석이 다르면 해당 항목만 고친다(리포트 주의사항).
