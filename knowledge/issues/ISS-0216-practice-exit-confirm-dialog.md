---
type: issue
id: ISS-0216
created: 2026-10-07
topics: [practice]
symptoms: ["풀이 중 홈 아이콘", "시스템 뒤로가기", "확인 없이 홈 이동", ChapterAppBar, "이탈 확인 다이얼로그"]
root_cause: "풀이 화면의 홈 아이콘·시스템 뒤로가기에 이탈 확인 단계가 없었다"
status: resolved
resolution: "[[ISS-0216-practice-exit-confirm-dialog-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/371"
---

# ISS-0216: 풀이 중 홈·뒤로가기를 누르면 확인 없이 나가 진행 흐름을 잃음 (앱)

GitHub #371 (원본: 이슈 본문과 완료 댓글). GitHub #370 후보 1.

## 증상
챕터 연습·오늘의 세트를 푸는 도중 왼쪽 위 홈 아이콘(또는 시스템 뒤로가기)을 누르면 확인 없이 바로 홈으로 나간다. 실수로 누르면 진행 중인 풀이 흐름을 잃는다.

## 재현 조건
QA GitHub #357, iPhone 16 Pro. 문제 탭 → 토픽 선택 → 1/10 진입 후 홈 아이콘 탭 → 확인 없이 홈으로 이동.

## 조사 기록
- 2026-10-07: 작업 범위 — 풀이를 시작한 뒤(제출했거나 2번째 문제 이상)에는 "풀이를 그만할까요?" 확인, 홈 아이콘과 시스템 뒤로가기 모두 같은 확인, 아무것도 안 했으면 바로 나감.

## 근본 원인
기능 이슈. 이탈 확인 단계가 없었다(원본 개요 기준). 코드상 원인은 원본에 적혀 있지 않다.
