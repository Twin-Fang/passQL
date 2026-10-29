---
type: completion-report
id: ISS-0405
created: 2026-10-26
topics: [home, ops-infra]
status: resolved
resolves: "[[ISS-0405-home-first-load-skeleton-wait]]"
related: ["[[DEC-0182-home-not-wait-recommendations]]"]
source: "https://github.com/Twin-Fang/passQL/issues/676"
---

# ISS-0405 완료 리포트: 추천 문제를 홈 첫 표시 조건에서 분리 (1단계)

GitHub #676 리포트 댓글(2026-10-26) 기준. 리포트는 1단계까지만 다루고 2단계(지난 데이터 기기 저장)는 남았다고 적었다. 이슈는 2026-10-27 닫혔다.

## 해결 방법
- `home_providers.dart`: `HomeData`에서 추천 문제 필드를 빼고 `homeDataProvider`는 인사말·일정 묶음과 학습 현황 묶음만 기다린다.
- `home_page.dart`: 추천 문제는 `homeRecommendationsProvider`를 따로 구독해 도착하면 맨 아래 섹션으로 표시(출제 경향 섹션과 같은 방식).
- `learning_refresh_test.dart`: 추천이 끝나지 않아도 홈 데이터가 완료되는지 테스트(수정 전 실패, 수정 후 통과).
- 추천 실패 시 기존처럼 섹션만 숨김. 인증 만료는 `safeCall`이 다시 던지고 인터셉터가 로그아웃 처리. `invalidateHomeData`는 추천 Provider도 함께 비운다.
- 별도 커밋으로 `dart format`(52개 파일, 동작 변경 없음).

## 근본 원인 (확정)
홈이 추천 문제(등급 확인 > 추천 직렬 약 2.5초)까지 기다렸다.

## 재발 방지
- 추천 문제를 다시 `homeDataProvider`에 합치지 않는다. `learning_refresh_test`의 `#676` 테스트가 막는다.
- 추천 섹션을 위로 옮기면 도착 시 아래 카드가 밀리므로 자리를 먼저 잡는 처리가 필요.
- 측정 한계: 디버그·시뮬레이터, 핫 리스타트라 앱 시작 단계(Firebase 초기화, 세션 복원) 제외.
- 남은 작업: 2단계 SWR, 추천 문제 자체 약 2.5초의 서버 쪽 원인 확인.

## 교훈
(원본에 없음, 볼트 정리) 첫 화면 스켈레톤이 길면 가장 느린 섹션이 전체 표시 조건에 묶여 있는지부터 본다.
