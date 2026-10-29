---
type: completion-report
id: ISS-0365
created: 2026-10-24
topics: [progress-stats]
status: resolved
resolves: "[[ISS-0365-profile-bar-shows-total-questions]]"
related: ["[[DEC-0174-never-show-total-question-count]]"]
source: "https://github.com/Twin-Fang/passQL/issues/609"
---

# ISS-0365 완료 리포트: 막대를 `solvedCount` 기준 상대 비율로, 카드 제목 "카테고리별 푼 문제"

GitHub #609 리포트 댓글(`## 개요`, 2026-10-24) 기준.

## 해결 방법
- `bar_chart_section.dart`: 막대 길이와 숫자를 `totalQuestionCount` → `solvedCount`, 가장 많이 푼 카테고리를 100%로 하는 비율, 모두 0이면 빈 막대, 스크린리더 "N문제 풀었어요", 카드 제목 "카테고리별 푼 문제".
- `client/src/components/StatsBarChart.tsx`: 웹은 이미 `solvedCount`라 카드 제목만 통일.

## 근본 원인 (확정)
앱 위젯이 `totalQuestionCount`를 읽었다.

## 재발 방지
- 검증: `flutter analyze` 이상 없음, 탭 화면 테스트 40개 통과, 실제 폰트(Pretendard) 위젯 렌더로 라이트·다크·0개 계정 확인. 로그인이 막혀 실기기 화면은 미확인.
- 주의: 서버 `/progress/topic-analysis`의 `totalQuestionCount`는 그대로라 네트워크에서는 보인다(제거하려면 서버 DTO와 `api-contract/openapi.json` 함께 변경). 출제 경향 화면의 "N문항 · 20%"는 경향 분석 문항 수라 유지. iOS 1.44.0 빌드에는 미포함.

## 교훈
(원본에 없음, 볼트 정리) 같은 응답을 앱·웹이 따로 그리면 필드 선택이 갈릴 수 있다 — 한쪽 수정 시 다른 쪽 필드를 대조한다.
