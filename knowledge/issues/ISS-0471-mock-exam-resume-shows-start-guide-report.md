---
type: completion-report
id: ISS-0471
created: 2026-11-07
topics: [practice]
status: resolved
resolves: "[[ISS-0471-mock-exam-resume-shows-start-guide]]"
related: ["[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
source: "https://github.com/Twin-Fang/passQL/issues/902"
---

# ISS-0471 완료 리포트: 풀이 중 회차는 목록에서 바로 이어 풀기, 안내 화면도 남은 시간 안내와 확인 없는 이어서 풀기

GitHub #902 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/902#issuecomment-6702223941). PR #906 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0471-mock-exam-resume-shows-start-guide-report.md`(로컬).

## 해결 방법
- `mock_exam_round_list_page.dart`: 마지막 응시가 풀이 중이면 `canStart`를 보기 전에 그 응시의 풀이 화면으로 바로 이동.
- `mock_exam_guide_page.dart`: 회차 목록 응답의 풀이 중 응시가 이 회차면 "풀이 중" 안내(남은 시간, 답한 문항 수), 버튼 "이어서 풀기", 시작 확인 창 생략. 서버 호출은 같은 `startOrResumeMockExam`.

## 검증
- `flutter analyze` 0건, `flutter test` 123개, 코드 점검 동결 규칙 11개 새 위반 0.

## 근본 원인 (확정)
서버 `canStart: true`가 "시작 또는 이어 풀기 가능"을 뜻하는데 앱 목록이 이를 "새로 시작"으로 다뤘다.

## 재발 방지
- 목록 분기에서 풀이 중 검사를 `canStart` 검사보다 앞에 둔다. 순서를 바꾸면 다시 안내 화면으로 간다.
- 안내 화면의 남은 시간은 목록을 받은 시점의 서버 값이라 머무는 동안 줄지 않는다. 마감 판정은 서버.

## 남은 일
- 앱 배포 뒤 실기기 확인은 후속 댓글.

## 교훈
서버의 가능 여부 플래그 하나가 여러 상태(새로 시작, 이어 풀기)를 함께 뜻하면, 화면은 플래그보다 상태(마지막 응시 상태)를 먼저 보고 분기해야 한다.
