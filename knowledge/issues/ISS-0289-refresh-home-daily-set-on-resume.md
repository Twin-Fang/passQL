---
type: issue
id: ISS-0289
created: 2026-10-15
topics: [home, practice]
symptoms: [앱 복귀 시 어제 세트, 날짜 변경 미반영, 인사말 히트맵 그대로, 생명주기 처리 없음, 문제 탭 당겨서 새로고침 없음]
root_cause: "앱 생명주기 처리가 없어 다음 날 백그라운드에서 돌아와도 데이터를 다시 받지 않았다"
status: resolved
resolution: "[[ISS-0289-refresh-home-daily-set-on-resume-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/483"
---

# ISS-0289: 앱 복귀나 날짜 변경 시 홈·오늘의 세트가 갱신되지 않음

GitHub #483 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 앱 생명주기 처리가 없어 다음 날 백그라운드에서 돌아오면 어제의 세트, 인사말, 히트맵이 그대로.
- 문제 탭에는 당겨서 새로고침이 없음.
- 위치: `app/lib/presentation/providers/home_providers.dart:36`, `topic_list_page.dart`.

## 재현 조건
앱을 백그라운드에 둔 채 날짜가 바뀐 뒤 복귀.

## 조사 기록
- 2026-10-15: 제안 — 앱 활성화 시 날짜가 바뀌었으면 학습 데이터와 오늘의 세트 재조회, 문제 탭 당겨서 새로고침.

## 근본 원인
frontmatter `root_cause`와 같음.
