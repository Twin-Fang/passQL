---
type: completion-report
id: ISS-0216
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0216-practice-exit-confirm-dialog]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/371"
---

# ISS-0216 완료 리포트: `ChapterAppBar` 이탈 확인 + `PopScope`로 뒤로가기도 같은 확인

GitHub #371 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `ChapterAppBar`에 `confirmExit` 추가: 한 문제라도 제출했거나 2번째 문제 이상이면 홈 아이콘 탭 시 "풀이를 그만할까요? / 지금까지 제출한 답은 학습 기록에 남아요." 확인.
- `ChapterPage`를 `PopScope`로 감싸 시스템 뒤로가기(Android 백 버튼·iOS 스와이프)도 같은 확인을 거친다.
- 아직 시작 전이면 확인 없이 바로 나간다.

## 근본 원인 (확정)
이탈 확인 단계가 없었다. 그 밖의 원인 설명은 원본에 적혀 있지 않다.

## 재발 방지
위젯 테스트 2건(확인→계속 풀기 머묾→나가기 홈 이동 / 시작 전 즉시 이동) 통과. 시뮬레이터 실측: 다이얼로그 표시 → 계속 풀기(유지) → 나가기(홈).

## 교훈
(원본에 없음, 볼트 정리) 풀이 화면의 이탈 경로는 앱바 버튼과 시스템 뒤로가기 두 가지다. 한쪽만 막으면 다른 쪽으로 샌다.
