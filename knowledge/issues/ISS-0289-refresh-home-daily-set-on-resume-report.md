---
type: completion-report
id: ISS-0289
created: 2026-10-15
topics: [home, practice]
status: resolved
resolves: "[[ISS-0289-refresh-home-daily-set-on-resume]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/483"
---

# ISS-0289 완료 리포트: `AppLifecycleRefresher`로 날짜 변경 시 재조회, 문제 탭 당겨서 새로고침

GitHub #483 구현 보고서 댓글 기준 (2차 통합 main `a402a0a`, 0.12.0).

## 해결 방법
- `AppLifecycleRefresher`(탭 쉘): 앱 복귀 시 날짜가 바뀌었으면 홈, 통계, 오늘의 세트, 순위를 다시 조회.
- 문제 탭에 당겨서 새로고침.
- 탭 쉘에서 GitHub #464 권장 업데이트 안내와 함께 감쌈.
- 검증: `flutter analyze` 경고 0, `flutter test` 292개 통과. Spring `38817742993`, AI `38817743033`, Vercel `38817742854`, Play `38817746746` 성공.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
원본에 별도 언급 없음.

## 교훈
원본에 없음.
