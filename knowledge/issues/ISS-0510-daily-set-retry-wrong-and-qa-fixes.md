---
type: issue
id: ISS-0510
created: 2026-11-12
topics: [practice, design-system, home]
symptoms: ["틀린 N문제 다시 풀기", "첫 오답 1문제만 열림", "wrongQuestions.first", "다시 맞혀도 결과 표 오답 그대로", "버튼 문구 숫자 안 줄어듦", "daily_set_result_page", "PassqlCodeBlock 줄바꿈 들여쓰기", "주석 뒷부분 새 SQL 문처럼 보임", "AS R1 정렬 깨짐", "지난 일정 N건 더 보기 버튼 위치", "exam_schedule_timeline", "모의고사 회차 목록 갱신 안 됨", "앱 밖 응시 미반영", "mock-exams/rounds"]
root_cause: "세트 결과 화면이 오답 중 첫 문제만 여는 경로를 만들고 다시 푼 결과를 담을 상태가 없었으며, 코드 블록은 넘친 줄을 줄 머리로 내렸고, 지난 일정 버튼은 펼침 위치와 반대편, 모의고사 회차 목록은 provider가 유지돼 재조회하지 않았다"
status: resolved
resolution: "[[ISS-0510-daily-set-retry-wrong-and-qa-fixes-report]]"
related: ["[[DEC-0300-daily-set-retry-correct-mark-memory-only]]", "[[DEC-0073-session-result-fixed-at-first-submit]]", "[[DEC-0089-shared-question-flow-for-solving]]", "[[ISS-0129-review-overwrites-original-result]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1035"
---

# ISS-0510: 11/12 QA 결함 — 오늘의 세트 오답 다시 풀기 외 3건 (앱)

GitHub #1035. 원본 사본: `_sources/issues/ISS-0510-daily-set-retry-wrong-and-qa-fixes.md`(로컬). QA 상세는 #999 댓글.

## 증상
v1.114.0 배포분 실기기 QA(iOS 시뮬레이터, 운영 서버)에서 앱 결함 4건.
1. [Medium] 오늘의 세트 `틀린 N문제 다시 풀기`가 첫 오답 1문제만 엶. 채점 결과 화면에 `닫기`만 있고, 정답으로 다시 풀고 돌아와도 결과 표(`오답`)·버튼 문구(`틀린 3문제`) 그대로, 다시 누르면 같은 첫 문제.
2. [Low] 좁은 폭에서 코드 블록 줄바꿈 뒷부분이 들여쓰기 없이 줄 머리로 내려감. 주석 뒷부분(`ON DELETE SET NULL`)이 새 SQL 문처럼 보이고 `AS R1,` 정렬 열이 깨짐.
3. [Low] 시험 일정 `지난 일정 N건 더 보기` 버튼은 목록 아래, 펼쳐지는 일정은 목록 위.
4. [Low] 앱 밖(웹 등)에서 응시한 모의고사가 앱 재실행 전까지 회차 목록·홈에 반영 안 됨.

## 재현 조건
1. 오답 2개 이상으로 세트 완료 > 결과 화면 다시 풀기 > 정답 제출 > 닫기.
2. EMP 행 수 문제, `SUBSTR('DATABASE', -4, 2) AS R1` 문제 코드 블록을 iPhone 폭에서 보기.
3. 홈 `시험 D-N` > 시험 일정 > 지난 일정 더 보기.
4. 웹·API로 모의고사 1회차 제출 > 앱에서 회차 화면 재진입.

## 조사 기록
- 2026-11-12: 이슈 등록(QA #999 댓글 근거), 위치 `daily_set_result_page.dart`(`wrongQuestions.first`), `PassqlCodeBlock`, `exam_schedule_timeline.dart`.
- 2026-11-12: 커밋 47d08b35, PR #1040. 검증 중 다시 풀기 완료 뒤 pop이 완료 잠금 창만 닫는 문제 발견, 한 박자 늦춰 수정.

## 근본 원인
- 다시 풀기: 결과 화면이 `wrongQuestions.first` 한 문제 경로만 만들고, 다시 푼 결과를 담는 상태가 없음.
- 코드 블록: 넘친 줄을 원래 줄 들여쓰기와 무관하게 줄 머리로 내림.
- 일정: 펼침 버튼이 펼쳐지는 자리와 반대편(목록 아래).
- 모의고사: 문제 탭 모의고사 행이 회차 목록 provider를 붙잡고 있어 재진입해도 다시 받지 않음.
